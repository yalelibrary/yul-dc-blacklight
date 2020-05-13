#!/bin/bash

mkdir -p solr
cp ./ladybird/*.json ./solr
sed -i '' 's/"oid"/"id"/g' ./solr/*.json
sed -i '' 's/"title"/"title_tsim"/g' ./solr/*.json
sed -i '' 's/"language"/"language_ssim"/g' ./solr/*.json
sed -i '' 's/"creator"/"author_tsim"/g' ./solr/*.json
sed -i '' 's/"description"/"description_ssim"/g' ./solr/*.json
sed -i '' 's/"orbisBibId"/"bib_id_ssm"/g' ./solr/*.json
sed -i '' 's/"alternativeTitle"/"alternativeTitle_tesim"/g' ./solr/*.json
sed -i '' 's/"source"/"source_ssim"/g' ./solr/*.json
sed -i '' 's/"recordType"/"recordType_ssim"/g' ./solr/*.json
sed -i '' 's/"ssim"/"uri_ssim"/g' ./solr/*.json
sed -i '' 's/"identifierMfhd"/"identifierMfhd_ssim"/g' ./solr/*.json
sed -i '' 's/"identifierShelfMark"/"identifierShelfMark_ssim"/g' ./solr/*.json
sed -i '' 's/"box"/"box_ssim"/g' ./solr/*.json
sed -i '' 's/"sourceTitle"/"sourceTitle_ssim"/g' ./solr/*.json
sed -i '' 's/"sourceDate"/"sourceDate_ssim"/g' ./solr/*.json
sed -i '' 's/"sourceNote"/"sourceNote_ssim"/g' ./solr/*.json
sed -i '' 's/"extentOfDigitization"/"extentOfDigitization_ssim"/g' ./solr/*.json
sed -i '' 's/"date"/"date_ssim"/g' ./solr/*.json
sed -i '' 's/"extent"/"extent_ssim"/g' ./solr/*.json
sed -i '' 's/"subjectName"/"subjectName_ssim"/g' ./solr/*.json
sed -i '' 's/"subjectTopic"/"subjectTopic_ssim"/g' ./solr/*.json
sed -i '' 's/"genre"/"genre_ssim"/g' ./solr/*.json
sed -i '' 's/"format"/"format_ssim"/g' ./solr/*.json
sed -i '' 's/"partOf"/"partOf_ssim"/g' ./solr/*.json
sed -i '' 's/"rights"/"rights_ssim"/g' ./solr/*.json
sed -i '' 's/"orbisBarcode"/"orbisBarcode_ssim"/g' ./solr/*.json
sed -i '' 's/"findingAid"/"findingAid_ssim"/g' ./solr/*.json
sed -i '' 's/"references"/"references_ssi./m"/g' ./solr/*.json
sed -i '' 's/"dateStructured"/"dateStructured_ssim"/g' ./solr/*.json
sed -i '' 's/"collectionId"/"collectionId_ssim"/g' ./solr/*.json
sed -i '' 's/"children"/"children_ssim"/g' ./solr/*.json
sed -i '' 's/"publicationPlace"/"publicationPlace_ssim"/g' ./solr/*.json
sed -i '' 's/"folder"/"folder_ssim"/g' ./solr/*.json
sed -i '' 's/"numberOfPages"/"numberOfPages_ssim"/g' ./solr/*.json
sed -i '' 's/"importUrl"/"importUrl_ssim"/g' ./solr/*.json
sed -i '' 's/"resourceType"/"resourceType_ssim"/g' ./solr/*.json
sed -i '' 's/"sourceCreated"/"sourceCreated_ssim"/g' ./solr/*.json
sed -i '' 's/"edition"/"edition_ssim"/g' ./solr/*.json
sed -i '' 's/"uri"/"uri_ssim"/g' ./solr/*.json
sed -i '' 's/"abstract"/"abstract_ssim"/g' ./solr/*.json
sed -i '' 's/"geoSubject"/"geoSubject_ssim"/g' ./solr/*.json
sed -i '' 's/"illustrativeMatter"/"illustrativeMatter_ssim"/g' ./solr/*.json
sed -i '' 's/"publisher"/"publisher_ssim"/g' ./solr/*.json
sed -i '' 's/"material"/"material_ssim"/g' ./solr/*.json
sed -i '' 's/"scale"/"scale_ssim"/g' ./solr/*.json
sed -i '' 's/"digital"/"digital_ssim"/g' ./solr/*.json
sed -i '' 's/"coordinates"/"coordinates_ssim"/g' ./solr/*.json
sed -i '' 's/"copyrightDate"/"copyrightDate_ssim"/g' ./solr/*.json
sed -i '' 's/"projection"/"projection_ssim"/g' ./solr/*.json
sed -i '' 's/}/  ,\
  "public_bsi": true\
}/g' ./solr/*.json # make works public for now
