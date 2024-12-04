$(document).ready(function() {
    const images = [
      {
        alt: 'Conference attendees at "Camp Spingarn," Amenia, N.Y., August 24-26, 1916',
        caption: 'Conference at "Camp Spingarn," Amenia, N.Y.',
        src: '<%= asset_path("landing/hero-images/camp-spingarn.jpg") %>',
      },
      {
        alt: 'Prologue the Gutenberg Bible',
        caption: 'From Gutenberg Bible, 1454',
        src: '<%= asset_path("landing/hero-images/gutenberg-bible.jpg") %>'
      },
      {
        alt: 'Portolan Chart of the Mediterranean Sea',
        caption: 'Portolan Chart of the Mediterranean Sea',
        src: '<%= asset_path("landing/hero-images/portolan-chart.jpg") %>',
      },
    ]

    const lastIndex = window.localStorage.getItem('lastIndex') || 0

    let index = Math.floor(Math.random() * images.length)
    while (index == lastIndex) {
      index = Math.floor(Math.random() * images.length)
    }
    window.localStorage.setItem('lastIndex', JSON.stringify(index))

    const alt = images[index].alt;
    const caption = images[index].caption;
    const src = images[index].src;

    $('#hero-image').attr({ 'src': src, 'alt': alt });
    $('#hero-image-caption').text(caption);
})
