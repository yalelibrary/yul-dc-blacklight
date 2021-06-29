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



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'
$('.blacklight-year_i').data('plot-config', {
    selection: { color: '#C0FF83' },
    colors: ['#ffffff'],
    series: { lines: { fillColor: 'rgba(255,255,255, 0.5)' }},
    grid: { color: '#aaaaaa', tickColor: '#aaaaaa', borderWidth: 0 }
});

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
    const search_field = document.getElementById("search_field");
    let options = search_field.options;

    // change placeholder
    changePlaceholderText();
}

$(document).on('turbolinks:load', function() {
    // Receiving the data:
    let useDefault = localStorage.getItem("useDefault");
    if(useDefault === null){
        useDefault = "true";
        localStorage.setItem("useDefault", "true")
    }
    if(localStorage.getItem("searchFieldValue") === null){
        localStorage.setItem("searchFieldValue", "all_fields")
    }
    useDefault = (useDefault === "true");

    // hide fulltext option in search fields
    hideFulltextOptions();
    changePlaceholderText();

    let descriptionButton = document.getElementById("fulltext_search_1");
    let fullTextButton = document.getElementById("fulltext_search_2");

    if(useDefault){
        descriptionButton.click();
    }
    else{
        fullTextButton.click();
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
    localStorage.setItem("useDefault", "true");
    const search_field = document.getElementById("search_field");
    search_field.style.visibility = 'visible';

    let options = search_field.options;
    let value = localStorage.getItem("searchFieldValue");
    for (let i = 0, optionsLength = options.length; i < optionsLength; i++) {
        if (options[i].value === value) {
            search_field.selectedIndex = i;
        }
    }
    changePlaceholderText();
    return true;
};

function onSelectFulltext(){
    localStorage.setItem("useDefault", "false");
    const search_field = document.getElementById("search_field");
    search_field.style.visibility = 'hidden';

    let options = search_field.options;
    let value = "fulltext_tesim";


    // don't save fulltext value
    if("fulltext_tesim" !== options[search_field.selectedIndex].value) {
        localStorage.setItem("searchFieldValue", options[search_field.selectedIndex].value);
    }

    for (let i = 0, optionsLength = options.length; i < optionsLength; i++) {
        if (options[i].value === value) {
            search_field.selectedIndex = i;
        }
    }
    changePlaceholderText();
    return false;
};

function hideFulltextOptions(){
    $('#search_field').children('option[value="fulltext_tesim"]').css('display','none');
}

$(document).on('turbolinks:load', function() {
    renderBanner();
});

function renderBanner() {
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
                    container.innerHTML = "<h3>" + banner.header + "</h3><p>" + banner.message + "</p>";
                    container.style.display = "block";
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
            $("#banner").remove();
        });
}