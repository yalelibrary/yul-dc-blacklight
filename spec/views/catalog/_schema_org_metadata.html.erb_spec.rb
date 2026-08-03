# frozen_string_literal: true

RSpec.describe 'catalog/_schema_org_metadata.html.erb' do
  let(:metadata) do
    {
      "@context": "https://schema.org/",
      "@type": "CreativeWork",
      name: ["A Title"],
      url: "https://collections.library.yale.edu/catalog/1234",
      about: [{ "@type": "Thing", name: "Cats" }]
    }
  end

  def render_partial(data = metadata)
    render partial: 'catalog/schema_org_metadata', locals: { metadata: data }
  end

  def script_body
    Capybara.string(rendered).find('script[type="application/ld+json"]', visible: :all).text(:all)
  end

  def json_ld
    JSON.parse(script_body)
  end

  it 'renders a single JSON-LD script tag' do
    render_partial
    expect(Capybara.string(rendered).all('script[type="application/ld+json"]', visible: :all).size).to eq 1
  end

  it 'renders the metadata as parseable JSON' do
    render_partial
    expect(json_ld).to eq(JSON.parse(metadata.to_json))
  end

  it 'carries the content security policy nonce' do
    render_partial
    nonce = view.content_security_policy_nonce
    expect(nonce).to be_present
    expect(rendered).to have_selector("script[nonce='#{nonce}']", visible: :all)
  end

  it 'emits JSON string escapes rather than HTML entity escapes' do
    render_partial(name: ["Dogs & Cats: an author's \"study\""])
    expect(json_ld["name"]).to eq(["Dogs & Cats: an author's \"study\""])
    # Asserted explicitly so losing the `html_safe` fails here for an obvious reason.
    expect(rendered).not_to include('&amp;', '&quot;', '&#39;')
  end

  context 'when a field is empty' do
    it 'still renders valid JSON' do
      render_partial({})
      expect(json_ld).to eq({})
    end
  end

  # Defence in depth -- the model layer removes this markup. ActiveSupport's #to_json
  # escapes <, > and &, so a value cannot terminate the script element early; plain
  # JSON.generate/JSON.dump would not.
  it 'escapes markup rather than emitting a second script element' do
    render_partial(name: ["</script><script>alert(1)</script>"])
    expect(Capybara.string(rendered).all('script', visible: :all).size).to eq 1
    expect(script_body).not_to include('<', '>')
  end

  # Sanitizing lives in SchemaOrgSolrDocument#to_schema_json_ld, which this spec does not
  # exercise; see spec/models/solr_document_spec.rb.
end
