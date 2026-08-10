# frozen_string_literal: true
# Pin npm packages by running ./bin/importmap

# Entry point for the ES modules this app loads alongside the sprockets bundle.
# Deliberately NOT named "application" -- app/assets/javascripts/application.js
# already claims that logical path in sprockets, and importmap-rails adds
# app/javascript to the sprockets load path.
pin "range_limit", preload: true

# blacklight-range-limit itself does not need a pin here: its engine appends its
# own config/importmap.rb to importmap.paths.
#
# Its dependencies do. chart.js does not currently work as a vendored importmap,
# so it has to be pinned to a live CDN -- which means ga.jspm.io must stay in the
# script_src allowlist in config/initializers/content_security_policy.rb.
# These version numbers only move when changed here by hand.
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.2.0/dist/chart.js"
# single dependency of chart.js:
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"
