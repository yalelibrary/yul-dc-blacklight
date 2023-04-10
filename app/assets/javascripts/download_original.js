$(document).on('turbolinks:load', function () {
    const stagedBlurb = $('.tiff-staged');
    const fullPath = window.location.pathname;
    const hostPath = window.location.origin;
    const childOid = fullPath.replace(/\D/g, '');
    if (stagedBlurb.length) {
        checkAvailability(childOid, hostPath);
    }
})


var retryCount = 0;
function checkAvailability(childOid, hostPath) {
    $.ajax({
        url: hostPath + '/download/tiff/' + childOid + '/available',
        complete: function(r) {
            if (r.responseText === 'false' && retryCount < 10) {
                retryCount = retryCount + 1;
                setTimeout(()=> checkAvailability(childOid, hostPath), 30000);
            } else if (retryCount === 10) {
                $('#download-instructions').html('The file could not be downloaded at this time. Please try again later.');
            } else if (r.responseText === 'true') {
                window.location.href = hostPath + '/download/tiff/' + childOid;
                setTimeout(() => window.close(), 60000);
            }
        }
    });
}