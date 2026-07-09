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
        return {
          paraCount: el ? el.querySelectorAll('p').length : 0,
          text: p ? p.textContent : null,
          bg: el ? el.style.backgroundColor : null,
          color: el ? el.style.color : null,
          display: el ? el.style.display : null,
          imgCount: el ? el.querySelectorAll('img').length : 0,
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

  context 'when the message contains HTML (supply-chain / XSS attempt)' do
    let(:state) do
      banner_state(banners: { global: [{ message: '<img src=x onerror="window.__xss=true">hello' }] })
    end

    it 'renders the markup as inert text instead of executing it' do
      expect(state['imgCount']).to eq(0)
      expect(state['xss']).to be_nil
      expect(state['text']).to eq('<img src=x onerror="window.__xss=true">hello')
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
