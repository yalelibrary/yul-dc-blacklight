// Renders the "Terms & Conditions" metadata block after the Rights row, with
// expand/truncate controls bound via addEventListener. The terms body HTML is
// provided server-side inside a <template id="grouped-metadata-terms-template">
// element to avoid attribute-escaping issues (the body may contain rich HTML).
//
// Replaces the previous inline <script> in _grouped_metadata.html.erb which
// used innerHTML string concatenation to inject onclick= handlers — blocked
// by strict CSP.
$(document).on('turbolinks:load', function() {
  const template = document.getElementById('grouped-metadata-terms-template');
  if (!template) return;

  // Idempotency: bail out if the terms block has already been inserted
  // (turbolinks may fire this handler more than once per page lifecycle).
  if (document.querySelector('dd.blacklight-terms')) return;

  const rights = document.querySelector('dd.blacklight-rights_ssim');
  if (!rights) return;

  const fragment = document.createDocumentFragment();

  const dtTerms = document.createElement('dt');
  dtTerms.className = 'blacklight-terms metadata-block__label-key';
  dtTerms.textContent = 'Terms & Conditions';
  fragment.appendChild(dtTerms);

  const ddTerms = document.createElement('dd');
  ddTerms.className = 'blacklight-terms metadata-block__label-value metadata-block__label-value--yul line-clamp-five';
  ddTerms.appendChild(template.content.cloneNode(true));
  fragment.appendChild(ddTerms);

  const dtShow = document.createElement('dt');
  dtShow.className = 'blacklight-terms_show_truncate_link';
  fragment.appendChild(dtShow);

  const ddShow = document.createElement('dd');
  ddShow.className = 'blacklight-terms_show_truncate_link metadata-block__label-value metadata-block__label-value--yul';
  ddShow.textContent = 'Show Full Terms & Conditions';
  fragment.appendChild(ddShow);

  const dtHide = document.createElement('dt');
  dtHide.className = 'blacklight-terms_hide_truncate_link';
  fragment.appendChild(dtHide);

  const ddHide = document.createElement('dd');
  ddHide.className = 'blacklight-terms_hide_truncate_link metadata-block__label-value metadata-block__label-value--yul';
  ddHide.textContent = 'Hide Full Terms & Conditions';
  fragment.appendChild(ddHide);

  rights.parentNode.insertBefore(fragment, rights.nextSibling);

  function expand() {
    ddTerms.classList.remove('line-clamp-five');
    dtShow.classList.add('hidden');
    ddShow.classList.add('hidden');
    dtHide.classList.remove('hidden');
    ddHide.classList.remove('hidden');
  }

  function truncate() {
    ddTerms.classList.add('line-clamp-five');
    dtShow.classList.remove('hidden');
    ddShow.classList.remove('hidden');
    dtHide.classList.add('hidden');
    ddHide.classList.add('hidden');
  }

  ddShow.addEventListener('click', expand);
  ddHide.addEventListener('click', truncate);

  // Initial visibility mirrors the original: only show the toggle if the body
  // is actually being truncated.
  if (ddTerms.offsetHeight < ddTerms.scrollHeight ||
      ddTerms.offsetWidth < ddTerms.scrollWidth) {
    dtShow.classList.remove('hidden');
    ddShow.classList.remove('hidden');
    dtHide.classList.add('hidden');
    ddHide.classList.add('hidden');
  } else {
    dtShow.classList.add('hidden');
    ddShow.classList.add('hidden');
    dtHide.classList.add('hidden');
    ddHide.classList.add('hidden');
  }
});
