// Turbolinks 5 + strict CSP nonce reconciliation.
(function() {
  if (typeof Turbolinks === 'undefined') {
    console.warn('[csp-nonce] Turbolinks is not defined; skipping patch.');
    return;
  }

  var originalNonce = null;

  function captureOriginalNonce() {
    var meta = document.querySelector('meta[name="csp-nonce"]');
    originalNonce = meta && meta.getAttribute('content');
    if (originalNonce) {
      window.__cspNoncePatched = originalNonce;
    } else {
      console.warn('[csp-nonce] No meta[name="csp-nonce"] in head; rewriter has nothing to write.');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', captureOriginalNonce);
  } else {
    captureOriginalNonce();
  }

  function makePatch(originalFn) {
    return function(element) {
      var created = originalFn.call(this, element);
      if (originalNonce && element && element.hasAttribute && element.hasAttribute('nonce')) {
        try { created.nonce = originalNonce; } catch (e) { /* ignore */ }
      }
      return created;
    };
  }

  var patched = false;

  if (Turbolinks.Renderer && Turbolinks.Renderer.prototype &&
      typeof Turbolinks.Renderer.prototype.createScriptElement === 'function') {
    Turbolinks.Renderer.prototype.createScriptElement =
      makePatch(Turbolinks.Renderer.prototype.createScriptElement);
    patched = true;
  }

  if (Turbolinks.SnapshotRenderer && Turbolinks.SnapshotRenderer.prototype &&
      Object.prototype.hasOwnProperty.call(
        Turbolinks.SnapshotRenderer.prototype, 'createScriptElement'
      ) &&
      typeof Turbolinks.SnapshotRenderer.prototype.createScriptElement === 'function') {
    Turbolinks.SnapshotRenderer.prototype.createScriptElement =
      makePatch(Turbolinks.SnapshotRenderer.prototype.createScriptElement);
    patched = true;
  }

  if (!patched) {
    console.warn('[csp-nonce] Could not find Turbolinks.Renderer.createScriptElement to patch.');
  }
})();
