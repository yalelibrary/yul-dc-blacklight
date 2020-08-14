# frozen_string_literal: true
require 'github_changelog_generator/task'

namespace :yale do
  namespace :release do
    desc "Release yul-dc-blacklight"
    task blacklight: :environment do
      if Rails.env.production?
        puts "This task should not be run in production"
      else
        client = Octokit::Client.new(access_token: ENV['CHANGELOG_GITHUB_TOKEN'])
        last_release = client.releases('yalelibrary/yul-dc-blacklight')[0]
        last_version_number = last_release[:name]
        new_version_number = get_new_version_number(client)
        log = get_release_notes(last_version_number, new_version_number)
        release_options = { name: new_version_number, body: log }
        client.create_release('yalelibrary/yul-dc-blacklight', new_version_number, release_options)
      end
    end
  end
end

##
# Generate release notes for all PRs merged since the last release
def get_release_notes(last_version_number, new_version_number)
  options = GitHubChangelogGenerator::Parser.default_options
  options[:user] = 'yalelibrary'
  options[:project] = 'yul-dc-blacklight'
  options[:since_tag] = last_version_number
  options[:future_release] = new_version_number
  options[:token] = ENV['CHANGELOG_GITHUB_TOKEN']
  options[:enhancement_labels] = ["Feature"]
  options[:bug_labels] = ["Bug", "Bugs", "bug", "bugs"]
  options[:enhancement_prefix] = "**New Features:**"
  options[:merge_prefix] = "**Technical Enhancements:**"
  options[:security_labels] = ["dependencies", "security"]
  generator = GitHubChangelogGenerator::Generator.new options
  generator.compound_changelog
end

##
# Fetch all the merged PRs since the last release, and determine whether any of
# them had a "Feature" label. If so, increment the minor part of the version number.
# If not, increment the patch part of the version number.
def get_new_version_number(client)
  last_release = client.releases('yalelibrary/yul-dc-blacklight')[0]
  last_version_number = last_release[:name]
  last_release_timestamp = last_release[:created_at]
  pull_requests = client.pulls 'yalelibrary/yul-dc-blacklight', state: 'closed'
  release_prs = pull_requests.select { |a| a[:merged_at] && a[:merged_at] > last_release_timestamp }
  labels = release_prs.map { |a| a[:labels] }.reject!(&:empty?)
  union_labels = []
  labels.each { |a| a.each { |b| union_labels << b[:name] } }
  new_feature = union_labels.include?("Feature")
  major, minor, patch = last_version_number.split(".")
  minor = minor.to_i + 1 if new_feature
  patch = patch.to_i + 1 unless new_feature
  "#{major}.#{minor}.#{patch}"
end
