# frozen_string_literal: true

class PermissionRequestsController < ApplicationController

  def prep_request
    # TODO: revert to ENV['MANAGEMENT_HOST']
    url = URI.parse("http://yul-dc_management_1:3001/management/api/permission_requests")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      'oid': params['oid'],
      'user_email': current_user.email,
      'user_full_name': params['permission_request']['user_full_name'],
      'user_netid': current_user.netid,
      'user_note': params['permission_request']['user_note']
      'user_sub': current_user.sub,

    })
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }
    # TODO: make sure that these are the right variables - write test
    handle_response(con.response.status, con.response.title)
  end

  def handle_response(http_status, title)
    if http_status == 400 && title == 'Invalid Parent OID'
      render "catalog/#{params['oid']}/request_form", notice: 'Object not found'
    elsif http_status == 400 && title == 'Parent Object is private'
      render "catalog/#{params['oid']}/request_form", notice: title
    elsif http_status == 400 && title == 'Parent Object is public, permission not required'
      render "catalog/#{params['oid']}/request_form", notice: title
    elsif http_status == 403
      render "catalog/#{params['oid']}/request_form", notice: 'Too many pending requests'
    elsif http_status == 201
      render "catalog/#{params['oid']}/request_confirmation", notice: 'Your requests has been submitted for review by Library staff'
    else
      render "catalog/#{params['oid']}/request_form", notice: "#{con.response.error}"
    end
  end

  private 

  def permission_request_params
    params.require(:permission_request).permit(:oid, :user_sub, :user_email, :user_full_name, :user_note, :user_netid)
  end
end
