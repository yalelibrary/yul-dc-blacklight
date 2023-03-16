$(document).on('turbolinks:load', function () {
    const stagedBlurb = $('.tiff-staged');

    if (stagedBlurb.length) {
        const fullPath = window.location.pathname;
        const hostPath = window.location.origin;
        const childOid = fullPath.replace(/\D/g, '');

        // check if file is on S3
        const available = $.ajax(hostPath + '/download/tiff/' + childOid + '/available');

        // create loop that checks for the file every minute
        function sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }
        do {
            sleep(60000);
            available;
        } while (available.responseText == 'false')

        if (available.responseText == 'true') {
            // trigger download once
            const download = $.ajax(hostPath + '/download/tiff/' + childOid)
            download
        }
    }

})
