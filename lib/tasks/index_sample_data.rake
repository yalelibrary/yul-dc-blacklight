# frozen_string_literal: true

namespace :yale do
  desc "Load sample data"
  task load_voyager_sample_data: :environment do
    vis = VoyagerIndexingService.new
    ladybird_metadata_path = Rails.root.join('spec', 'fixtures', 'ladybird').to_s
    voyager_metadata_path =  Rails.root.join('spec', 'fixtures', 'voyager').to_s
    vis.voyager_metadata_path = voyager_metadata_path
    vis.ladybird_metadata_path = ladybird_metadata_path
    vis.index_voyager_metadata
    puts "Voyager sample metadata indexed"
  end

  desc "Delete all solr documents"
  task clean_solr: :environment do
    solr = Blacklight.default_index.connection
    solr.delete_by_query '*:*'
    solr.commit
    puts "All documents deleted from solr"
  end
end
