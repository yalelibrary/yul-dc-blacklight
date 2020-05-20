# frozen_string_literal: true

# The DEPLOYED_AT file should contain the iso8601 timestamp of when it was deployed
# can be done by running: date -u +%FT%TZ
# which gives output that looks like: 2020-05-19T23:47:41Z

GITSHA_FILENAME = Rails.root.join('GIT_SHA')
GITBRANCH_FILENAME = Rails.root.join('GIT_BRANCH')
DEPLOYEDAT_FILENAME = Rails.root.join('DEPLOYED_AT')

GIT_SHA =
  if File.exist?(GITSHA_FILENAME)
    File.read(GITSHA_FILENAME).strip
  else
    sha = `git log -1 --pretty=%h`.strip
    if $CHILD_STATUS == 0
      sha
    else
      'Unknown SHA'
    end
  end

GIT_BRANCH =
  if File.exist?(GITBRANCH_FILENAME)
    File.read(GITBRANCH_FILENAME).strip
  else
    branch = `git rev-parse --abbrev-ref HEAD`.strip
    if $CHILD_STATUS == 0
      branch
    else
      'Unknown branch'
    end
  end

DEPLOYED_AT =
  if File.exist?(DEPLOYEDAT_FILENAME)
    timestamp = File.read(DEPLOYEDAT_FILENAME).strip
    Time.iso8601(timestamp).in_time_zone('Eastern Time (US & Canada)').to_formatted_s(:iso8601)
  else
    "Not in deployed environment"
  end
