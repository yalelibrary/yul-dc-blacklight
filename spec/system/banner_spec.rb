# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Banner', type: :system, js: true, clean: true do
  before do
    visit "/catalog"
  end

  def banner_state(*payloads)
    applies = payloads.map { |p| "applyBanner(#{p.to_json});" }.join("\n")
    page.evaluate_script(<<~JS)
      (function() {
        var el = document.getElementById('banner');
        if (!el) { el = document.createElement('div'); el.id = 'banner'; document.body.prepend(el); }
        el.textContent = '';
        el.removeAttribute('style');
        #{applies}
        el = document.getElementById('banner');
        var p = el && el.querySelector('p');
        var a = el && el.querySelector('a');
        return {
          paraCount: el ? el.querySelectorAll('p').length : 0,
          text: p ? p.textContent : null,
          bg: el ? el.style.backgroundColor : null,
          color: el ? el.style.color : null,
          display: el ? el.style.display : null,
          imgCount: el ? el.querySelectorAll('img').length : 0,
          boldCount: el ? el.querySelectorAll('b').length : 0,
          linkCount: el ? el.querySelectorAll('a').length : 0,
          linkHref: a ? a.getAttribute('href') : null,
          linkText: a ? a.textContent : null,
          xss: (typeof window.__xss === 'undefined') ? null : window.__xss
        };
      })();
    JS
  end

  context 'with a well-formed banner' do
    let(:state) do
      banner_state(banners: { global: [{ message: 'Library closed Monday',
                                         backgroundColor: '#003366',
                                         textColor: '#ffffff' }] })
    end

    it 'renders the message as a single paragraph and makes the banner visible' do
      expect(state['text']).to eq('Library closed Monday')
      expect(state['paraCount']).to eq(1)
      expect(state['display']).to eq('block')
    end

    it 'applies valid #RRGGBB colors' do
      expect(state['bg']).to eq('rgb(0, 51, 102)')
      expect(state['color']).to eq('rgb(255, 255, 255)')
    end
  end

  context 'when the message contains dangerous HTML (supply-chain / XSS attempt)' do
    let(:state) do
      banner_state(banners: { global: [{ message: '<img src=x onerror="window.__xss=true">hello' }] })
    end

    it 'strips the dangerous element and never executes it, keeping safe text' do
      expect(state['imgCount']).to eq(0)
      expect(state['xss']).to be_nil
      # The disallowed <img> is dropped; its surrounding text survives.
      expect(state['text']).to eq('hello')
    end
  end

  context 'when the message contains a safe link' do
    let(:state) do
      banner_state(banners: { global: [{ message: 'See <a href="https://library.yale.edu/news">the news</a>' }] })
    end

    it 'preserves the link as a real, clickable anchor' do
      expect(state['linkCount']).to eq(1)
      expect(state['linkHref']).to eq('https://library.yale.edu/news')
      expect(state['linkText']).to eq('the news')
      expect(state['text']).to eq('See the news')
    end
  end

  context 'when a link uses a dangerous URL scheme' do
    let(:state) do
      banner_state(banners: { global: [{ message: '<a href="javascript:window.__xss=true">click</a>' }] })
    end

    it 'keeps the text but drops the unsafe href so nothing can execute' do
      expect(state['xss']).to be_nil
      expect(state['linkHref']).to be_nil        # javascript: href rejected
      expect(state['linkText']).to eq('click')
    end
  end

  context 'when the message uses non-link tags' do
    let(:state) do
      banner_state(banners: { global: [{ message: '<script>window.__xss=true</script>hi <b>there</b>' }] })
    end

    it 'drops dangerous tags and flattens other formatting to text (only links are kept)' do
      expect(state['xss']).to be_nil
      expect(state['text']).to eq('hi there')
      # Only <a> is allowlisted, so <b> is unwrapped to plain text.
      expect(state['boldCount']).to eq(0)
    end
  end

  context 'when colors are not valid #RRGGBB values' do
    let(:state) do
      banner_state(banners: { global: [{ message: 'hi',
                                         backgroundColor: 'red; background-image: url(evil)',
                                         textColor: '#fff' }] })
    end

    it 'rejects malformed and 3-digit shorthand hex colors' do
      expect(state['bg']).to eq('')
      expect(state['color']).to eq('')
    end
  end

  context 'when applyBanner runs more than once (turbolinks re-render)' do
    let(:state) do
      banner_state({ banners: { global: [{ message: 'first' }] } },
                   { banners: { global: [{ message: 'second' }] } })
    end

    it 'does not create duplicate paragraphs' do
      expect(state['paraCount']).to eq(1)
      expect(state['text']).to eq('second')
    end
  end

  context 'with malformed or empty feed data' do
    it 'does not raise for missing or empty structures' do
      expect { banner_state({}) }.not_to raise_error
      expect { banner_state(banners: {}) }.not_to raise_error
      expect { banner_state(banners: { global: [] }) }.not_to raise_error
      expect { banner_state(banners: { global: [{}] }) }.not_to raise_error
    end
  end
end
