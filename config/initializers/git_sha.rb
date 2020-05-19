# frozen_string_literal: true

# note: cmd -  date -u +%FT%TZ
# note: output - 2020-05-19T23:47:41Z

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

# TODO: Will need updating. Needs to be handled by deployment code
# Can just dump simple timestamp to be read here
DEPLOYED_AT =
  if File.exist?(DEPLOYEDAT_FILENAME)
    timestamp = File.read(DEPLOYEDAT_FILENAME).strip
    Time.iso8601(timestamp).to_formatted_s(:rfc822)
  else
    "Not in deployed environment"
  end
