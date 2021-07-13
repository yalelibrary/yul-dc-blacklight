$(document).on('turbolinks:load', function () {
    $('.show-more-button').on('click', function (e) {
        e.preventDefault();
        $(this).parent().fadeOut({duration:100});
        $(this).parent().siblings(".show-more-hidden-text").fadeIn({duration:1000});
    })
})