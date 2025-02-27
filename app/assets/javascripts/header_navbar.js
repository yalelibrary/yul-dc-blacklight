// override the addClass method so that a callback can be used
(function($) {
    let oldAddClass = $.fn.addClass;
    $.fn.addClass = function() {
        for (let i in arguments) {
            let arg = arguments[i]
            if (!!(arg && arg.constructor && arg.call && arg.apply)) {
                setTimeout(arg.bind(this))
                delete arguments[i]
            }
        }
        return oldAddClass.apply(this, arguments)
    }

})(jQuery)

// show and hide the dropdown links properly
$(document).ready(function() {
    console.log('something')
    $('.secondary-nav .nav-link-title').click(function(e) {
        const width = window.innerWidth
        || document.documentElement.clientWidth
        || document.body.clientWidth
        
        $('.secondary-nav .content-yul').addClass('content-show', function() {
            const contentBlock = $('.secondary-nav .dropdown .show .menu-block-wrapper')
            const blockHeight = 410

            if (contentBlock) {
                if (width >= 1200) {
                    $('.content-yul').height(blockHeight + 20)
                } else {
                    // on devices smaller than 1200px wide, only show the item that was clicked on
                    $('.secondary-nav .dropdown .show .content-yul').height(blockHeight + 20)
                    $('.secondary-nav .dropdown:not(.show) .content-yul').height(0)
                }
            } else {
                $('.content-yul').height(0)
            }
        })
    })

    $('body').on('click', function(e) {
        if (
            !$(e.target).is('.secondary-nav .nav-link-title') && !$(e.target).is('.secondary-nav .nav-link-title li a')||
            $(e.target).is('.sort-dropdown') ||
            $(e.target).is('.per-page-dropdown')
        ) {
            $('.secondary-nav .content-yul').removeClass('content-show')
            $('.content-yul').height(0)
        }
    })
})

