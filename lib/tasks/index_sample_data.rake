# frozen_string_literal: true

namespace :yale do

  desc "Delete all solr documents"
  task clean_solr: :environment do
    solr = Blacklight.default_index.connection
    solr.delete_by_query '*:*'
    solr.commit
    puts "All documents deleted from solr"
  end
end
