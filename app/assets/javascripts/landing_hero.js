// Landing page hero carousel.
// Image list (with Rails asset paths resolved) is provided via a `data-hero-images`
// JSON attribute on the #hero element so this module can live outside of ERB.
$(document).ready(function() {
  const hero = document.getElementById('hero');
  if (!hero || !hero.dataset.heroImages) return;

  let images;
  try {
    images = JSON.parse(hero.dataset.heroImages);
  } catch (e) {
    return;
  }
  if (!Array.isArray(images) || images.length === 0) return;

  const lastIndex = window.localStorage.getItem('lastIndex') || 0;

  let index = Math.floor(Math.random() * images.length);
  while (images.length > 1 && index == lastIndex) {
    index = Math.floor(Math.random() * images.length);
  }
  window.localStorage.setItem('lastIndex', JSON.stringify(index));

  const { alt, caption, src } = images[index];

  $('#hero-image').attr({ 'src': src, 'alt': alt });
  $('#hero-image-caption').text(caption);
});
