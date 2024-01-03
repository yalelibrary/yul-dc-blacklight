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
    when 'Open with Permission'
      return true if client_can_view_owp?(document)
    end
    false
  end

  def client_can_view_owp?(document)
    Rails.logger.warn("starting client can view digital check for #{request.env['HTTP_X_ORIGIN_URI']}")
    return true if object_owp?(document) && user_has_permission?(document)
    false
  end

  def object_owp?(document)
    case document['visibility_ssi']
    when 'Open with Permission'
      return true
    end
    false
  end

  def pending_request?(document)
    parent_oid = document[:id]
    return unless current_user
    user_owp_permissions['permissions']&.each do |permission|
      if (permission['oid'].to_s == parent_oid) && !permission['request_date'].nil? && (permission['request_status'] == false)
        true
      else
        false
      end
    end
  end

  def user_has_permission?(document)
    parent_oid = document[:id]
    allowance = false
    return unless current_user
    user_owp_permissions['permissions']&.each do |permission|
      if (permission['oid'].to_s == parent_oid) && (permission['access_until'].nil? || Time.zone.parse(permission['access_until']) > Time.zone.today) && (permission['request_status'] == true)
        allowance = true
      end
    end
    allowance
  end

  def user_owp_permissions
    return nil if current_user.nil?
    # for local debugging - http://yul-dc-management-1:3001/management or http://yul-dc_management_1:3001/management
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{current_user.sub}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  def client_can_view_metadata?(document)
    viewable_metadata_visibilities.include? document['visibility_ssi']
  end

  # rubocop:disable Layout/LineLength
  # rubocop:disable Rails/OutputSafety
  def restriction_message(document)
    case document['visibility_ssi']
    when 'Yale Community Only'
      return "The digital version of this work is restricted due to copyright or other restrictions."
    when 'Open with Permission'
      return "You are currently logged in to your account. However, you do not have permission to view this folder. If you would like to request permission, please fill out this #{link_to 'form', "/catalog/#{document.id}/request_form"}.".html_safe
    end
    "The digital version is restricted."
  end
  # rubocop:disable Layout/LineLength
  # rubocop:disable Rails/OutputSafety

  def restriction_instructions(document)
    case document['visibility_ssi']
    when 'Yale Community Only'
      return "Please log in using your Yale NetID or contact library staff to inquire about access to a physical copy."
    end
    "You are not authorized to view this item."
  end
end
