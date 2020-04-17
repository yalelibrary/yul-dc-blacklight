RSpec.describe VoyagerIndexingService do
  it "can be instantiated" do
    vis = VoyagerIndexingService.new
    expect(vis).to be_instance_of(VoyagerIndexingService)
  end
end
