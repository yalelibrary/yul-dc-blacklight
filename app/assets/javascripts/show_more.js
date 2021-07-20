$(document).on('turbolinks:load', function () {
    $('.show-more-button').on('click', function (e) {
        e.preventDefault();
        $(this).parent().fadeOut({duration:100});
        $(this).parent().siblings(".show-more-hidden-text").fadeIn({duration:1000});
    })
})
$(document).on('turbolinks:load', function () {
    $('.show-full-tree-button').on('click', function (e) {
        e.preventDefault();
        $(this).parent().fadeOut({duration:100});
        $(".show-full-tree-hidden-text").fadeIn({duration:1000});
    })
})