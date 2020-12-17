# frozen_string_literal: true
module AccessHelper
  def self.viewable_metadata_visibilities
    ["Public", "Yale Community Only"]
  end

  def client_can_access(document)
    case document['visibility_ssi']
    when 'Public'
      return true
    when 'Yale Community Only'
      return true if current_user || User.on_campus?(request.remote_ip)
    end
    false
  end

  def client_can_view_metadata(document)
    AccessHelper.viewable_metadata_visibilities.include? document['visibility_ssi']
  end

  def restriction_message(document)
    case document['visibility_ssi']
    when 'Yale Community Only'
      return "Please login using your Yale NetID or contact library staff to inquire about access to a physical copy."
    end
    "You are not authorized to view this item."
  end
end
