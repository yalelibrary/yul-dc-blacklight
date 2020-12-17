# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::MetadataPresenter do
  subject(:presenter) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context) }

  let(:config) { CatalogController.blacklight_config }
  let(:request_context) { instance_double('View context', should_render_field?: true, blacklight_config: config) }
  let(:controller) { double }
  let(:params) { {} }
  let(:search_state) { Blacklight::SearchState.new(params, config, controller) }

  before do
    allow(request_context).to receive(:search_state).and_return(search_state)
  end

  context '#metadata_fields_to_render with block' do
    let(:migration_source_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    it 'returns only MS fields in block' do
      record_found = false
      source_found = false
      counter = 0
      migration_source_presenter_object.metadata_fields_to_render('migration_source') do |field, _field_config|
        record_found = true if field.include? 'recordType_ssi'
        source_found = true if field.include? 'source_ssim'
        counter += 1
      end
      expect(record_found).to be_truthy
      expect(source_found).to be_truthy
      expect(counter).to be 2
    end
  end

  context 'with a description document' do
    let(:description_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { description_presenter_object.metadata_fields_to_render('description') }
    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Abstract Key' do
          expect(fields.any? { |field| field.include? 'abstract_tesim' }).to be_truthy
        end

        it 'returns the Alternative Title Key' do
          expect(fields.any? { |field| field.include? 'alternativeTitle_tesim' }).to be_truthy
        end

        it 'returns the Description Key' do
          expect(fields.any? { |field| field.include? 'description_tesim' }).to be_truthy
        end

        it 'returns the Extent Key' do
          expect(fields.any? { |field| field.include? 'extent_ssim' }).to be_truthy
        end

        it 'returns the Extent of Digitization Key' do
          expect(fields.any? { |field| field.include? 'extentOfDigitization_ssim' }).to be_truthy
        end

        it 'returns the Number of Pages Key' do
          expect(fields.any? { |field| field.include? 'numberOfPages_ssim' }).to be_truthy
        end

        it 'returns the Projection Key' do
          expect(fields.any? { |field| field.include? 'projection_tesim' }).to be_truthy
        end

        it 'returns the References Key' do
          expect(fields.any? { |field| field.include? 'preferredCitation_tesim' }).to be_truthy
        end

        it 'returns the Scale Key' do
          expect(fields.any? { |field| field.include? 'scale_tesim' }).to be_truthy
        end
      end
    end
  end

  context 'with an identifier document' do
    let(:identifier_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { identifier_presenter_object.metadata_fields_to_render('identifier') }
    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Box Key' do
          expect(fields.any? { |field| field.include? 'containerGrouping_ssim' }).to be_truthy
        end

        it 'returns the Finding Aid Key' do
          expect(fields.any? { |field| field.include? 'findingAid_ssim' }).to be_truthy
        end

        it 'returns the Folder Key' do
          expect(fields.any? { |field| field.include? 'folder_ssim' }).to be_truthy
        end

        it 'returns the Identifier MFHD Key' do
          expect(fields.any? { |field| field.include? 'identifierMfhd_ssim' }).to be_truthy
        end

        it 'returns the Call Number Key' do
          expect(fields.any? { |field| field.include? 'callNumber_ssim' }).to be_truthy
        end

        it 'returns the Orbis Bib ID Key' do
          expect(fields.any? { |field| field.include? 'orbisBibId_ssi' }).to be_truthy
        end

        it 'returns the OID Key' do
          expect(fields.any? { |field| field.include? 'oid_ssi' }).to be_truthy
        end

        it 'returns the URI Key' do
          expect(fields.any? { |field| field.include? 'uri_ssim' }).to be_truthy
        end

        it 'returns the More Information Key' do
          expect(fields.any? { |field| field.include? 'url_suppl_ssim' }).to be_truthy
        end
      end
    end
  end

  context 'with a keyword document' do
    let(:keyword_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { keyword_presenter_object.metadata_fields_to_render('keyword') }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Format Key' do
          expect(fields.any? { |field| field.include? 'format' }).to be_truthy
        end

        it 'returns the Genre Key' do
          expect(fields.any? { |field| field.include? 'genre_ssim' }).to be_truthy
        end

        it 'returns the Geo Subject Key' do
          expect(fields.any? { |field| field.include? 'subjectGeographic_tesim' }).to be_truthy
        end

        it 'returns the Material Key' do
          expect(fields.any? { |field| field.include? 'material_tesim' }).to be_truthy
        end

        it 'returns the Resource Type Key' do
          expect(fields.any? { |field| field.include? 'resourceType_ssim' }).to be_truthy
        end
      end
    end
  end

  context 'with a migration source document' do
    let(:migration_source_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { migration_source_presenter_object.metadata_fields_to_render('migration_source') }
    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Record Type Key' do
          expect(fields.any? { |field| field.include? 'recordType_ssi' }).to be_truthy
        end

        it 'returns the Source Key' do
          expect(fields.any? { |field| field.include? 'source_ssim' }).to be_truthy
        end
      end
    end
  end

  context 'with an origin document' do
    let(:origin_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { origin_presenter_object.metadata_fields_to_render('origin') }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Coordinates Key' do
          expect(fields.any? { |field| field.include? 'coordinates_ssim' }).to be_truthy
        end

        it 'returns the Copyright Date Key' do
          expect(fields.any? { |field| field.include? 'copyrightDate_ssim' }).to be_truthy
        end

        it 'returns the Date Key' do
          expect(fields.any? { |field| field.include? 'date_ssim' }).to be_truthy
        end

        it 'returns the Digital Key' do
          expect(fields.any? { |field| field.include? 'digital_ssim' }).to be_truthy
        end

        it 'returns the Edition Key' do
          expect(fields.any? { |field| field.include? 'edition_ssim' }).to be_truthy
        end

        it 'returns the Language Key' do
          expect(fields.any? { |field| field.include? 'language_ssim' }).to be_truthy
        end

        it 'returns the Publication Place Key' do
          expect(fields.any? { |field| field.include? 'creationPlace_ssim' }).to be_truthy
        end

        it 'returns the Publisher Key' do
          expect(fields.any? { |field| field.include? 'publisher_ssim' }).to be_truthy
        end

        it 'returns the Source Created Key' do
          expect(fields.any? { |field| field.include? 'sourceCreated_tesim' }).to be_truthy
        end

        it 'returns the Source Date Key' do
          expect(fields.any? { |field| field.include? 'sourceDate_tesim' }).to be_truthy
        end

        it 'returns the Source Edition Key' do
          expect(fields.any? { |field| field.include? 'sourceEdition_tesim' }).to be_truthy
        end

        it 'returns the Source Note Key' do
          expect(fields.any? { |field| field.include? 'sourceNote_tesim' }).to be_truthy
        end

        it 'returns the Source Title Key' do
          expect(fields.any? { |field| field.include? 'sourceTitle_tesim' }).to be_truthy
        end
      end
    end
  end

  context 'with a usage document' do
    let(:usage_presenter_object) { described_class.new(SolrDocument.new(WORK_WITH_ALL_FIELDS), request_context, config) }
    let(:fields) { usage_presenter_object.metadata_fields_to_render('usage') }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Rights Key' do
          expect(fields.any? { |field| field.include? 'rights_ssim' }).to be_truthy
        end
      end
    end
  end
end
