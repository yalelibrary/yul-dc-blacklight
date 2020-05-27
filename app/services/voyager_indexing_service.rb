# frozen_string_literal: true

require 'json'
class VoyagerIndexingService
  # Define a location for voyager and ladybird metadata.
  # We expect the metadata to be a directory of .json files
  attr_accessor :voyager_metadata_path
  attr_accessor :ladybird_metadata_path

  # Index a directory of voyager json files
  def index_voyager_metadata
    Dir.foreach(voyager_metadata_path) do |filename|
      next if (filename == '.') || (filename == '..')
      index_voyager_json_file(File.join(voyager_metadata_path, filename))
    end
  end

  def oid_hash
    @oid_hash ||= build_oid_hash
  end

  ##
  # since we currently use bib to loop for oids we need storage for format
  def format_hash
    @format_hash ||= {}
  end

  ##
  # Read in a directory of ladybird json files and create a hash mapping orbisBibId to oid
  # Blacklight will need the oid in order to fetch the image for display.
  def build_oid_hash
    oid_hash = {}
    Dir.foreach(ladybird_metadata_path) do |filename|
      begin
        next if (filename == '.') || (filename == '..') || filename.match(/.swp/)
        file = File.read(File.join(ladybird_metadata_path, filename))
        data_hash = JSON.parse(file)
        orbis_bib_id = data_hash["orbisBibId"].to_s
        oid = data_hash["oid"].to_s
        oid_hash[orbis_bib_id] ||= []
        oid_hash[orbis_bib_id] << oid
        format_hash[oid] = data_hash['format']
      # TODO: We need a better way to surface parsing errors
      # Ideally these would go to an error tracking service that someone would review
      rescue JSON::ParserError => e
        puts "JSON::ParserError for #{filename}: #{e}"
      end
    end
    oid_hash
  end

  # Index a single voyager metadata json file
  # @param [String] filename - a full path to a json file
  def index_voyager_json_file(filename)
    file = File.read(File.join(filename))
    data_hash = JSON.parse(file)
    orbis_bib_id = data_hash["orbisBibId"].to_s
    oid_hash[orbis_bib_id].flatten.each do |oid|
      solr_doc = {
        id: oid,
        title_tsim: data_hash["title"],
        language_ssim: data_hash["language"],
        description_tesim: data_hash["description"],
        author_tsim: data_hash["creator"],
        bib_id_ssm: orbis_bib_id,
        public_bsi: data_hash["public"].presence || 0,
        format: format_hash[oid],
        extent_ssim: 'this is an example of extent, using ssim',
        partOf_ssim: "this is the part of, using ssim",
        numberOfPages_ssim: "this is the number of pages, using ssim",
        material_ssim: "this is the material, using ssim",
        scale_ssim: "this is the scale, using ssim",
        digital_ssim: "this is the digital, using ssim",
        coordinates_ssim: "this is the coordinates, using ssim",
        projection_ssim: "this is the projection, using ssim"
      }
      solr = Blacklight.default_index.connection
      solr.add([solr_doc])
      solr.commit
    end
  end
end
