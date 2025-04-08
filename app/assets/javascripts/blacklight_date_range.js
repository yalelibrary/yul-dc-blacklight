$('.blacklight-year_i').data('plot-config', {
    selection: { color: '#C0FF83' },
    colors: ['#ffffff'],
    series: { lines: { fillColor: 'rgba(255,255,255, 0.5)' }},
    grid: { color: '#aaaaaa', tickColor: '#aaaaaa', borderWidth: 0 }
});

// override blacklight date range facet behavior that hid the Apply button post upgrade to Bootstrap 5
$(document).on('turbolinks:load', function () {
    const submitButtons = $('.range-limit-input-group :input[value="Apply"]');
    $.each(submitButtons, function( index, value ) {
        $(value).removeClass('sr-only');
    })
});

$(document).on('turbolinks:load', function () {
    $("#blacklight-modal").on('show.bs.modal', function () {
        const submitButtons = $('.range-limit-input-group :input[value="Apply"]');
        $.each(submitButtons, function( index, value ) {
            $(value).removeClass('sr-only');
        })
    })
});