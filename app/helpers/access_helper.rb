# frozen_string_literal: true
module AccessHelper
  def viewable_metadata_visibilities
    ["Public", "Yale Community Only"]
  end

  def client_can_view_digital?(document)
    Rails.logger.warn("starting client can view digital check for #{request.env['HTTP_X_ORIGIN_URI']}")
    case document['visibility_ssi']
    when 'Public'
      return true
    when 'Yale Community Only'
      return true if current_user || User.on_campus?(request.remote_ip)
    end
    false
  end

  def client_can_view_metadata?(document)
    viewable_metadata_visibilities.include? document['visibility_ssi']
  end

  def restriction_message(document)
    case document['visibility_ssi']
    when 'Yale Community Only'
      return "The digital version of this work is restricted due to copyright or other restrictions."
    end
    "The digital version is restricted."
  end

  def restriction_instructions(document)
    case document['visibility_ssi']
    when 'Yale Community Only'
      return "Please log in using your Yale NetID or contact library staff to inquire about access to a physical copy."
    end
    "You are not authorized to view this item."
  end
end
