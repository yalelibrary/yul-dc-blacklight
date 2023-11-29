# frozen_string_literal: true

class PermissionRequestsController < ApplicationController

  def prep_request
    # create a permission request in blacklight to save the data and be able to be updated later
    permission_request = PermissionRequest.new(
      oid: params['oid'],
      user_sub: params['user_sub'], 
      user_email: params['user_email'],
      user_full_name: params['user_full_name'],
      user_note: params['user_note'],
      user_netid: params['user_netid'])
    permission_request.save
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_requests")
    req = Net::HTTP::Post.new(url.path)
    # pass the params from the form to the management app
    req.set_form_data(params)
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }
    # redirect to request page with flash message if not successfull
    # redirect to confirmation page if successfull
    redirect root_path
  end
end
