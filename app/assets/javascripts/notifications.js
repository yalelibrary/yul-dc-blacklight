// override blacklight flash message behavior that created a double close X button post upgrade to Bootstrap 5
$(document).on('turbolinks:load', function () {
    const closeButton = $('#main-flashes .close');
    closeButton.removeClass('btn-close');
});