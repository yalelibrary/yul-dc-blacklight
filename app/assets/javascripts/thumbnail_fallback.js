// Swaps in the "image not found" placeholder when a thumbnail fails to load.
// Replaces a previously-inline `onerror` attribute, which strict CSP blocks
// (`script_src_attr :none`).
function applyThumbnailFallback(img) {
    var fallbackSrc = img.dataset.fallbackSrc;
    if (!fallbackSrc) return;
    // Clear first so a failing placeholder can't loop back into this handler.
    delete img.dataset.fallbackSrc;
    img.src = fallbackSrc;
}

function bindThumbnailFallbacks() {
    document.querySelectorAll('img[data-fallback-src]').forEach(function (img) {
        img.addEventListener('error', function () {
            applyThumbnailFallback(img);
        }, { once: true });

        // `loading="lazy"` images can fail before this runs; a completed image
        // with no intrinsic width has already errored, so no event is coming.
        if (img.complete && img.naturalWidth === 0) {
            applyThumbnailFallback(img);
        }
    });
}

$(document).on('turbolinks:load', bindThumbnailFallbacks);
