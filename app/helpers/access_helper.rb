# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength
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
      return true if client_can_view_owp?(document) || admin_of_owp?(document)
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
    pending = false
    return unless current_user
    user_owp_permissions['permissions']&.each do |permission|
      pending = true if (permission['oid'].to_s == parent_oid) && !permission['request_date'].nil? && (permission['request_status'] == "Pending")
    end
    pending
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def user_has_permission?(document)
    return unless current_user
    parent_oid = params[:oid].presence || document[:id]
    return false if parent_oid.nil?
    allowance = false
    user_owp_permissions['permissions']&.each do |permission|
      if (permission['oid'].to_s == parent_oid) && (permission['access_until'].nil? || Time.zone.parse(permission['access_until']) > Time.zone.today) && (permission['request_status'] == "Approved")
        allowance = true
      end
    end
    allowance
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  def admin_of_owp?(document)
    return unless current_user
    @credentials = if params[:oid].present?
                     retrieve_admin_fulltext_credentials(params[:oid])
                   else
                     retrieve_admin_credentials(document)
                   end
    allowance = false
    allowance = true if @credentials['is_admin_or_approver?'] == "true"
    allowance
  end

  def user_owp_permissions
    return nil if current_user.nil?
    # for local debugging - http://yul-dc-management-1:3001/management or http://yul-dc_management_1:3001/management
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{current_user.sub}")
    response = Net::HTTP.get_response(url, { 'Authorization' => "Bearer #{ENV['OWP_AUTH_TOKEN']}" })
    JSON.parse(response.body)
  end

  def retrieve_permission_set_terms
    return nil if current_user.nil?
    # #{ENV['MANAGEMENT_HOST']}
    # for local debugging - http://yul-dc-management-1:3001/management or http://yul-dc_management_1:3001/management
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{@document[:id]}/terms")
    response = Net::HTTP.get_response(url, { 'Authorization' => "Bearer #{ENV['OWP_AUTH_TOKEN']}" })
    JSON.parse(response.body) unless response.nil?
  end

  def retrieve_admin_credentials(document)
    return nil if current_user.nil? || current_user&.netid.nil?
    # #{ENV['MANAGEMENT_HOST']}
    # for local debugging - http://yul-dc-management-1:3001/management or http://yul-dc_management_1:3001/management
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{document.id}/#{current_user.netid}")
    response = Net::HTTP.get_response(url, { 'Authorization' => "Bearer #{ENV['OWP_AUTH_TOKEN']}" })
    JSON.parse(response.body)
  end

  def retrieve_admin_fulltext_credentials(document)
    return nil if current_user.nil? || current_user&.netid.nil?
    # #{ENV['MANAGEMENT_HOST']}
    # for local debugging - http://yul-dc-management-1:3001/management or http://yul-dc_management_1:3001/management
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{document}/#{current_user.netid}")
    response = Net::HTTP.get_response(url, { 'Authorization' => "Bearer #{ENV['OWP_AUTH_TOKEN']}" })
    JSON.parse(response.body)
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
      return "You are currently logged in to your account. However, you do not have permission to view this folder. If you would like to request permission, please fill out this #{link_to 'form', "/catalog/#{document.id}/request_form", data: { turbolinks: false }}.".html_safe
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
# rubocop:enable Metrics/ModuleLength
