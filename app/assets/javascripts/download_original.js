$(document).on('turbolinks:load', function () {
    const stagedBlurb = $('.tiff-staged');
    const fullPath = window.location.pathname;
    const hostPath = window.location.origin;
    const childOid = fullPath.replace(/\D/g, '');
    if (stagedBlurb.length) {
        check_availability(childOid, hostPath);
    }
})


function check_availability(childOid, hostPath) {
    $.ajax({
        url: hostPath + '/download/tiff/' + childOid + '/available',
        complete: function(r) {
            if (r.responseText === 'false') {
                setTimeout(()=> check_availability(childOid, hostPath), 30000)
            } else if (r.responseText === 'true') {
                window.location.href = hostPath + '/download/tiff/' + childOid
                setTimeout(() => window.close(), 3000);
            }
        }
    });
}