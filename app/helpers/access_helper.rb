# frozen_string_literal: true
module AccessHelper
  def viewable_metadata_visibilities
    ["Public", "Yale Community Only", "Open with Permission"]
  end

  def client_can_view_digital?(document)
    Rails.logger.warn("starting client can view digital check for #{request.env['HTTP_X_ORIGIN_URI']}")
    case document['visibility_ssi']
    when 'Public'
      return true
    when 'Yale Community Only'
      return true if (current_user && current_user.netid.present?) || User.on_campus?(request.remote_ip)
    end
    false
  end

  def client_can_view_owp?(document)
    Rails.logger.warn("starting client can view digital check for #{request.env['HTTP_X_ORIGIN_URI']}")
    return true if document['visibility_ssi'] == 'Open with Permission' && user_has_permission?(document)
    false
  end

  def object_owp?(document)
    case document['visibility_ssi']
    when 'Open with Permission'
      return true
    end
    false
  end

  def user_has_permission?(document)
    parent_oid = document[:id]
    if current_user
      retrieve_user_permissions['permissions'].each do |permission|
        return true if (permission['oid'].to_s == parent_oid) && Time.zone.parse(permission['access_until']) > Time.zone.today
      end
    end
    false
  end

  def retrieve_user_permissions
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{current_user.sub}") if current_user
    response = Net::HTTP.get(url)
    JSON.parse(response)
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

  # rubocop:disable Layout/LineLength
  # rubocop:disable Rails/OutputSafety
  def owp_login_message(document)
    case document['visibility_ssi']
    when 'Open with Permission'
      "The material in this folder is open for research use only with permission. Researchers who wish to gain access or who have received permission to view this item, please #{link_to 'log in', user_openid_connect_omniauth_authorize_path, method: :post} to your account to request permission or to view the materials in this folder.".html_safe
    end
  end

  def owp_restriction_message(document)
    case document['visibility_ssi']
    when 'Open with Permission'
      "You are currently logged in to your account. However, you do not have permission to view this folder. If you would like to request permission, please fill out this form."
    end
  end
  # rubocop:disable Layout/LineLength
  # rubocop:disable Rails/OutputSafety
end
