# frozen_string_literal: true

class PermissionRequestsController < ApplicationController
  def prep_request
    if current_user.nil?
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}", notice: 'Please log in to request access to these materials.')
      return false
    end
    # TODO: Revert back to ENV['MANAGEMENT_HOST']
    url = URI.parse("http://yul-dc_management_1:3001/management/api/permission_requests")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
                        'oid': params['oid'],
                        'user_email': current_user.email,
                        'user_full_name': params['permission_request']['user_full_name'],
                        'user_netid': current_user.netid,
                        'user_note': params['permission_request']['user_note'],
                        'user_sub': current_user.sub
                      })
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }

    handle_request_response(response.status, response.body)
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def handle_request_response(http_status, body)
    if http_status == 400 && body == 'Invalid Parent OID'
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_form", notice: 'Object not found')
    elsif http_status == 400 && body == 'Parent Object is private'
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_form", notice: body)
    elsif http_status == 400 && body == 'Parent Object is public, permission not required'
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_form", notice: body)
    elsif http_status == 403
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_form", notice: 'Too many pending requests')
    elsif http_status == 201 || http_status == 200
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_confirmation", notice: 'Your request has been submitted for review by Library staff')
    else
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}/request_form", notice: "An error has occured.  Please try again later.")
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def permission_request_params
    params.require(:permission_request).permit(:oid, :user_sub, :user_email, :user_full_name, :user_note, :user_netid)
  end
end
