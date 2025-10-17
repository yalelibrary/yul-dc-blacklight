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
//= require blacklight_date_range
//= require download_original
//= require notifications
//= require show_more
// For blacklight_range_limit built-in JS
//= require blacklight_range_limit

/**
 * Setup button functionality.
 *
 * Buttons with 'href-button' class will be setup to follow the button tags href property when the button is clicked.
 * This allows us to setup an onclick event for all buttons with this class in the JS file rather than adding the
 * JS to each button. It follows the links using Turbolinks.
 *
 * Anchor links with 'convert-to-button' will be converted to buttons.  This allows us to pass a class to blacklight
 * code that generates a link, and then the link will get converted into a button.
 * The button gets the 'href-button' class so that when it is clicked, the href is followed.
 * (It helps us change blacklight functionality without having to pull in the generation code and changing it.)
 *
 * These only work when links contain simple hrefs and don't execute Javascript, etc.
 *
 * Turbolinks:
 * turbolinks:load is equivalent to document ready for non-turbolink pages.  It's called after the page loads.
 * Turbolinks.visit() is equivalent to setting document.location, but using turbolinks when possible.
 */
$(document).on('turbolinks:load', function() {
    $(".convert-to-button").each(function(ix, element) {
        if (element.tagName === "A") {
            let buttonElement = $(element.outerHTML.replace(/^<a/, "<button").replace(/<\/a>$/, "</button>"));
            buttonElement.addClass("href-button");
            buttonElement.removeClass("convert-to-button");
            $(element).replaceWith(buttonElement);
        }
    });
    $(".href-button").click(function (e){
        let href = $(this).attr("href");
        e.preventDefault();
        if (href) Turbolinks.visit(href);
    });
});

function onChangeSearchFields() {
    changePlaceholderText();
}


$(document).on('turbolinks:load', function() {
    // Receiving the data:
    let fullTextSearchSelected = new RegExp('[\?&]search_field=([^&#]*)').exec(window.location.href);
    fullTextSearchSelected = fullTextSearchSelected && fullTextSearchSelected[1] === 'fulltext_tesim'

    let descriptionButton = document.getElementById("fulltext_search_1");
    let fullTextButton = document.getElementById("fulltext_search_2");

    if (fullTextSearchSelected) {
        fullTextButton.click();
    } else if($("#fulltext_search_1").is(":visible")) {
        descriptionButton.click();
    }
});

function changePlaceholderText(){
    // change placeholder
    const search_field = document.getElementById("search_field");
    let options = search_field.options;

    switch ( options[search_field.selectedIndex].value) {
        case "all_fields":
            $("#q").attr('placeholder','Search words about the items');
            break;
        case "fulltext_tesim":
            $("#q").attr('placeholder',"Search words within the items");
            break;
        default:
            $("#q").attr('placeholder',"Search");
            break;
    }
}

// Toggle the fulltext
function onSelectDescription() {
    const search_field = $("#search_field");
    search_field.find("option[value='fulltext_tesim']").remove();
    search_field.css({visibility: 'visible'});
    if ( search_field.val() === "fulltext_tesim") {
        search_field.val('all_fields');
    }
    changePlaceholderText();
    return true;
};

function onSelectFulltext(){
    const search_field = $("#search_field");
    if (search_field.find("option[value='fulltext_tesim']").length === 0) {
        search_field.append("<option value=\"fulltext_tesim\">Full Text</option>")
    }
    search_field.css({visibility: 'hidden'});
    search_field.val("fulltext_tesim")
    changePlaceholderText();
    return false;
};

// Toggle the fulltext button
$(document).on('turbolinks:load', function() {
    const fulltextTranscription = $('.item-page-fulltext-wrapper .row')
    fulltextTranscription.addClass('hidden')

    $('.fulltext-button').click(function() {
        const fulltext_button = $(this)
        fulltextTranscription.toggle(function(i, text) {
            $(this).is(':visible') ? fulltext_button.text('Hide Full Text') : fulltext_button.text('Show Full Text')
        })
        fulltextTranscription.css('display', 'flex')
    })

    // Toggle the caption button
    $('.caption-toggle-button').click(function() {
        const caption_button = $(this)
        const captionContent = $('.matching-captions-content')
        captionContent.toggle()
        if (captionContent.is(':visible')) {
            caption_button.text('Hide Captions')
        } else {
            caption_button.text('Show Captions')
        }
    })
});

// 'uv-pages' is undefined by default
// the setTimeout waits until 'uv-pages' has text in it before getting the text
$(document).ready(() => {
    window.addEventListener('message', () => {
        setTimeout(fulltext, 250)
    }, false)
})

// Get the full text and render it on screen
const fulltext = () => {
    // check if fulltext is present on page
    const fulltextTranscription = $('.item-page-fulltext-wrapper .row')
    fulltextTranscription.empty() // Delete the old full text
    // check if fulltext is present on child object - button will only display if 'has_fulltext_ssi' is Yes
    if($('.fulltext-button').length) {
        const child_oids_array = $('#uv-pages').html().split(' ')
        const pageWidth = child_oids_array.length === 1 ? 'col-md-12' : 'col-md-6'

        child_oids_array.forEach(async child_oid => {
            const transcription = await getFulltext(child_oid)
            if (child_oids_array.length === 1) {
                fulltextTranscription.empty()
            }   
            return fulltextTranscription.append(`<span class='${pageWidth}'>${transcription}</span>`)
        })
    } else {
        return
    }
}

const getFulltext = async (child_oid) => {
    const result = await $.ajax({
        type:'GET',
        url:`/annotation/oid/${$('#parent-oid').text()}/canvas/${child_oid}/fulltext`,
        data: {
            oid: $('#parent-oid').text(),
            child_oid: $('#uv-pages').text()
        },
    })
    return result.body.value
}

$(document).on('turbolinks:load', function() {
    renderBanner();
});

function renderBanner() {
    if (document.URL.indexOf('https://collections.library') !== -1) {
        fetch("https://banner.library.yale.edu/banner.json")
            .then(response => response.json())
            .then(data => {
                let allBanners = data.banners;
                if ("global" in allBanners) {
                    let banners = allBanners.global;
                    if (banners.length > 0) {
                        let banner = banners[0];
                        let container = document.getElementById("banner");
                        // Code to apply text and background color directly
                        container.style.backgroundColor = banner.backgroundColor;
                        container.style.color = banner.textColor;
                        container.innerHTML = "<p>" + banner.message + "</p>";
                        container.style.display = "block";
                    }
                }
            })
            .catch(error => {
                console.error('Error:', error);
                $("#banner").remove();
            });
    } else {
        // Use test banner for all non prod environments
        fetch("https://banner.library.yale.edu/test/banner.json")
        .then(response => response.json())
        .then(data => {
            let allBanners = data.banners;
            if ("global" in allBanners) {
                let banners = allBanners.global;
                if (banners.length > 0) {
                    let banner = banners[0];
                    let container = document.getElementById("banner");
                    // Code to apply text and background color directly
                    container.style.backgroundColor = banner.backgroundColor;
                    container.style.color = banner.textColor;
                    container.innerHTML = "<p>" + banner.message + "</p>";
                    container.style.display = "block";
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
            $("#banner").remove();
        });
    }
}