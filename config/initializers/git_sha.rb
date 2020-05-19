# frozen_string_literal: true
revisions_logfile = "/opt/#{ENV['PROJECT_NAME']}/revisions.log"

sha = `git log -1 --pretty=%h`.strip
GIT_SHA =
  if $CHILD_STATUS == 0
    sha
  else
    'Unknown SHA'
  end

branch = `git rev-parse --abbrev-ref HEAD`.strip
BRANCH =
  if $CHILD_STATUS == 0
    branch
  else
    'Unknown branch'
  end

# TODO: Will need updating. Needs to be handled by deployment code
# Can just dump simple timestamp to be read here
LAST_DEPLOYED =
  if Rails.env.production? && File.exist?(revisions_logfile)
    deployed = `tail -1 #{revisions_logfile}`.chomp.split(" ")[7]
    Date.parse(deployed).strftime("%d %B %Y")
  else
    "Not in deployed environment"
  end
