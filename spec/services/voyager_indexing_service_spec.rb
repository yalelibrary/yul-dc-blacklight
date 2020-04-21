RSpec.describe VoyagerIndexingService, clean: true do

  let(:voyager_metadata_path) { File.join(fixture_path, 'voyager') }
  let(:vis) { VoyagerIndexingService.new }
  let(:voyager_json_file) { File.join(fixture_path, 'voyager', 'bid-752400.json') }

  it "can be instantiated" do
    expect(vis).to be_instance_of(VoyagerIndexingService)
  end

  it "knows where to find the voyager metadata" do
    vis.voyager_metadata_path = voyager_metadata_path
    expect(vis.voyager_metadata_path).to eq voyager_metadata_path
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

  it "indexes a single voyager json file" do
    vis.voyager_metadata_path = voyager_metadata_path
    vis.index_voyager_json_file(voyager_json_file)
    solr = Blacklight.default_index.connection
    response = solr.get 'select', :params => {:q => '*:*'}
    expect(response["response"]["numFound"]).to eq 1
  end
end
