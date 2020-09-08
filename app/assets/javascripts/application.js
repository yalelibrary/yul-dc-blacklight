//= require jquery
//= require 'blacklight_advanced_search'


//= require jquery3
//= require rails-ujs
//= require turbolinks
//
// Required by Blacklight
//= require popper
// Twitter Typeahead for autocomplete
//= require twitter/typeahead
//= require bootstrap
//= require blacklight/blacklight



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'
$('.blacklight-year_i').data('plot-config', {
    selection: { color: '#C0FF83' },
    colors: ['#ffffff'],
    series: { lines: { fillColor: 'rgba(255,255,255, 0.5)' }},
    grid: { color: '#aaaaaa', tickColor: '#aaaaaa', borderWidth: 0 }
});

