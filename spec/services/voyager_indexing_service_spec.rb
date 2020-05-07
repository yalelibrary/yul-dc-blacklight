# frozen_string_literal: true

RSpec.describe VoyagerIndexingService, clean: true do
  let(:vis) { VoyagerIndexingService.new }
  let(:voyager_metadata_path) { File.join(fixture_path, 'voyager') }
  let(:ladybird_metadata_path) { File.join(fixture_path, 'ladybird') }
  let(:voyager_json_file) { File.join(fixture_path, 'voyager', 'bid-752400.json') }

  it "can be instantiated" do
    expect(vis).to be_instance_of(VoyagerIndexingService)
  end

  it "knows where to find the voyager metadata" do
    vis.voyager_metadata_path = voyager_metadata_path
    expect(vis.voyager_metadata_path).to eq voyager_metadata_path
  end

  it "knows where to find the ladybird metadata" do
    vis.ladybird_metadata_path = ladybird_metadata_path
    expect(vis.ladybird_metadata_path).to eq ladybird_metadata_path
  end

  it "builds a hash mapping orbisBibId to oid" do
    vis.voyager_metadata_path = voyager_metadata_path
    vis.ladybird_metadata_path = ladybird_metadata_path
    oid_hash = vis.oid_hash
    expect(oid_hash["13881242"]).to eq ["16685691"]
  end

  # it "indexes a directory of voyager metadata" do
  #   allow(vis).to receive(:index_voyager_json_file).with(anything())
  #   vis.stub(:index_voyager_json_file).with(anything())
  #   vis.voyager_metadata_path = voyager_metadata_path
  #   vis.index_voyager_metadata
  #   expect(vis).to have_received(:index_voyager_metadata)
  #   # solr = Blacklight.default_index.connection
  #   # expect()
  # end

  it "indexes a voyager json file and merges it with the oid from ladybird" do
    vis.voyager_metadata_path = voyager_metadata_path
    vis.ladybird_metadata_path = ladybird_metadata_path
    vis.index_voyager_json_file(voyager_json_file)
    solr = Blacklight.default_index.connection
    response = solr.get 'select', params: { q: '*:*' }
    expect(response["response"]["numFound"]).to eq 1
    solr_doc = response["response"]["docs"][0]
    expect(solr_doc["id"]).to eq "2034600"
    expect(solr_doc["title_tsim"]).to eq ["Ebony"]
    expect(solr_doc["bib_id_ssm"]).to contain_exactly("752400")
  end
end
