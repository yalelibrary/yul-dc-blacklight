// blacklight_range_limit 9.x ships an ES module, so it is delivered by
// importmap-rails rather than the sprockets bundle in app/assets/javascripts.
//
// `Blacklight` is a global defined by the sprockets bundle. Module scripts are
// deferred, so that bundle has already executed by the time this runs, and
// deferred modules still execute before DOMContentLoaded -- so registering
// through Blacklight.onLoad here is not a race.
import BlacklightRangeLimit from "blacklight-range-limit";

BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });
