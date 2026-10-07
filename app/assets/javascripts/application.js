//= require google_tag_manager
// jQuery 3 only: jquery-rails' `jquery` is 1.12.4, whose feature detection sets
// on* attributes, causing a script-src-attr CSP violation.
//= require jquery3
//= require 'blacklight_advanced_search'
//= require rails-ujs
//= require turbolinks
//= require turbolinks_csp_nonce
//
// Required by Blacklight
//= require popper
// Twitter Typeahead for autocomplete
//= require twitter/typeahead
//= require bootstrap
//= require blacklight/blacklight
//= require download_original
//= require notifications
//= require show_more
//= require thumbnail_fallback
//= require landing_hero
//= require permission_requests_sort
//= require grouped_metadata
// blacklight_range_limit 9.x is an ES module, delivered via importmap: see
// config/importmap.rb and app/javascript/range_limit.js

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
    $(".href-button").on("click", function (e){
        let href = $(this).attr("href");
        e.preventDefault();
        if (href) Turbolinks.visit(href);
    });
});

function onChangeSearchFields() {
    changePlaceholderText();
}

// Delegated handlers replacing previously-inline event attributes (blocked by
// strict CSP since `script_src_attr :none`). Bound once at document level so
// they survive turbolinks navigations.
$(document).on('click', '.js-history-back', function(e) {
    e.preventDefault();
    history.back();
});

$(document).on('change', '[data-search-fields-trigger]', function() {
    onChangeSearchFields();
});

$(document).on('click', '[data-search-mode="description"]', function() {
    onSelectDescription();
});

$(document).on('click', '[data-search-mode="fulltext"]', function() {
    onSelectFulltext();
});


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

    $('.fulltext-button').on('click', function() {
        const fulltext_button = $(this)
        fulltextTranscription.toggle(function(i, text) {
            const expanded = $(this).is(':visible')
            fulltext_button.text(expanded ? 'Hide Full Text' : 'Show Full Text')
            fulltext_button.attr('aria-expanded', expanded)
        })
        fulltextTranscription.css('display', 'flex')
    })

    // Toggle the caption button
    $('.caption-toggle-button').on('click', function() {
        const caption_button = $(this)
        const captionContent = $('.matching-captions-content')
        captionContent.toggle()
        const expanded = captionContent.is(':visible')
        caption_button.text(expanded ? 'Hide Captions' : 'Show Captions')
        caption_button.attr('aria-expanded', expanded)
    })
});

// 'uv-pages' is undefined by default
// The setTimeout waits 250 ms for UV to load and _uv.html.erb JS put child OID(s) into 'uv-pages' div
$(() => {
    window.addEventListener('message', () => {
        // should we add a step to not do this if the parent or the child doesn't have fulltext?
        setTimeout(fulltext, 250)
    }, false)
})

// Get the fulltext and render it on screen
const fulltext = () => {
    // Check if fulltext is present on page
    const fulltextTranscription = $('.item-page-fulltext-wrapper .row')
    // Delete the old fulltext
    fulltextTranscription.empty()
    // Check if fulltext is present on parent object - button will only display if 'has_fulltext_ssi' is Yes or Partial
    if($('.fulltext-button').length) {
        // Get child OIDs - there may be one or two
        const child_oids_array = $('#uv-pages').html().split(' ')
        // Set page width based on number of child OIDs
        const pageWidth = child_oids_array.length === 1 ? 'col-md-12' : 'col-md-6'

        // Iterate over child OIDs and retrieve fulltext content
        child_oids_array.forEach(async child_oid => {
            // wait for retrieval of fulltext content
            const transcription = await getFulltext(child_oid)
            // if there is one child then delete the old text
            if (child_oids_array.length === 1) {
                fulltextTranscription.empty()
            }
            // add span with fulltext content to element with classes .item-page-fulltext-wrapper & .row
            return fulltextTranscription.append(`<span class='${pageWidth}'>${transcription}</span>`)
        })
    } else {
        return
    }
}

// Get the fulltext
const getFulltext = async (child_oid) => {
    // make ajax call to annotation link
    const result = await $.ajax({
        type:'GET',
        url:`/annotation/oid/${$('#parent-oid').text()}/canvas/${child_oid}/fulltext`,
        data: {
            oid: $('#parent-oid').text(),
            child_oid: child_oid
        },
    })
    return result.body.value
}

$(document).on('turbolinks:load', function() {
    renderBanner();
});

// Only accept a strict #RRGGBB hex color; reject anything else so a
// compromised banner host cannot inject arbitrary CSS values.
function sanitizeBannerColor(color) {
    return /^#[0-9a-fA-F]{6}$/.test(color) ? color : "";
}

function isSafeBannerHref(href) {
    return /^(https?:|mailto:)/i.test((href || "").trim());
}

var BANNER_ALLOWED_TAGS = { A: true };

var BANNER_DROP_TAGS = { SCRIPT: true, STYLE: true, TEMPLATE: true, NOSCRIPT: true, IFRAME: true, OBJECT: true, EMBED: true };

function sanitizeBannerNode(node) {
    if (node.nodeType === Node.TEXT_NODE) {
        return document.createTextNode(node.textContent);
    }
    if (node.nodeType !== Node.ELEMENT_NODE) {
        return document.createTextNode("");
    }
    if (BANNER_DROP_TAGS[node.tagName]) {
        return document.createDocumentFragment();
    }

    var target;
    if (BANNER_ALLOWED_TAGS[node.tagName]) {
        target = document.createElement(node.tagName.toLowerCase());
        if (node.tagName === "A") {
            var href = (node.getAttribute("href") || "").trim();
            if (isSafeBannerHref(href)) {
                target.setAttribute("href", href);
                target.setAttribute("rel", "noopener noreferrer");
            }
        }
    } else {
        target = document.createDocumentFragment();
    }

    node.childNodes.forEach(function(child) {
        target.appendChild(sanitizeBannerNode(child));
    });
    return target;
}

function sanitizeBannerMessage(message) {
    var fragment = document.createDocumentFragment();
    var doc = new DOMParser().parseFromString(String(message == null ? "" : message), "text/html");
    doc.body.childNodes.forEach(function(node) {
        fragment.appendChild(sanitizeBannerNode(node));
    });
    return fragment;
}

function applyBanner(data) {
    let allBanners = data.banners;
    if (!allBanners || !("global" in allBanners)) {
        return;
    }
    let banners = allBanners.global;
    if (banners.length === 0) {
        return;
    }
    let banner = banners[0];
    let container = document.getElementById("banner");
    if (!container) {
        return;
    }

    // Apply colors only when they pass strict #RRGGBB validation.
    let backgroundColor = sanitizeBannerColor(banner.backgroundColor);
    let textColor = sanitizeBannerColor(banner.textColor);
    if (backgroundColor) {
        container.style.backgroundColor = backgroundColor;
    }
    if (textColor) {
        container.style.color = textColor;
    }

    container.textContent = "";
    let paragraph = document.createElement("p");
    paragraph.appendChild(sanitizeBannerMessage(banner.message));
    container.appendChild(paragraph);
    container.style.display = "block";
}

function renderBanner() {
    let bannerUrl = document.URL.indexOf('https://collections.library') !== -1
        ? "https://banner.library.yale.edu/banner.json"
        // Use test banner for all non prod environments
        : "https://banner.library.yale.edu/test/banner.json";

    fetch(bannerUrl)
        .then(response => response.json())
        .then(applyBanner)
        .catch(error => {
            console.error('Error:', error);
            $("#banner").remove();
        });
}