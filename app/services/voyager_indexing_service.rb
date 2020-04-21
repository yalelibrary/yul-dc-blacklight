require 'json'
class VoyagerIndexingService

  # Define a location for voyager metadata. We expect the metadata to be a directory of .json files
  attr_accessor :voyager_metadata_path

  # Index a directory of voyager json files
  def index_voyager_metadata
    Dir.foreach(voyager_metadata_path) do |filename|
      next if filename == '.' or filename == '..'
      index_voyager_json_file(File.join(voyager_metadata_path, filename))
    end
  end

  # Index a single voyager metadata json file
  # @param [String] filename - a full path to a json file
  def index_voyager_json_file(filename)
    file = File.read(File.join(filename))
    data_hash = JSON.parse(file)
    solr_doc =     {
      id: data_hash["orbisBibId"],
      title_tsim: data_hash["title"],
      language_ssim: data_hash["language"],
      description_tesim: data_hash["description"],
      author_tsim: data_hash["creator"]
    }
    solr = Blacklight.default_index.connection
    solr.add([solr_doc])
    solr.commit
  end
end
