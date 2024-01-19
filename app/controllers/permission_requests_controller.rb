# frozen_string_literal: true

class PermissionRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def prep_request
    if current_user.nil?
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}", notice: 'Please log in to request access to these materials.')
      return false
    end
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/api/permission_requests")
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

  def agreement_term
    if current_user.nil?
      redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}", notice: 'Please log in to request access to these materials.')
      return false
    end
    url = URI.parse("#{ENV['MANAGEMENT_HOST']}/agreement_term")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
                        'oid': params['oid'],
                        'user_email': current_user.email,
                        'user_netid': current_user.netid,
                        'user_sub': current_user.sub,
                        'user_full_name': "new",
                        'permission_set_terms_id': params['permission_set_terms_id']
                      })
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }
    handle_agreement_request_response(response.status, response.body)
  end

  def handle_agreement_request_response(http_status, body)
    if http_status == 400 && body == 'Term not found.'
      redirect_to("/catalog/#{params[:oid]}", notice: 'Term not found')
    elsif http_status == 400 && body == 'User not found.'
      redirect_to("/catalog/#{params[:oid]}", notice: 'User not found.')
    elsif http_status == 201 || http_status == 200
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: 'Terms Accepted.')
    else
      redirect_to("/catalog/#{params[:oid]}", notice: "An error has occured.  Please try again later.")
    end
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def handle_request_response(http_status, body)
    if http_status == 400 && body == 'Invalid Parent OID'
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: 'Object not found')
    elsif http_status == 400 && body == 'Parent Object is private'
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: body)
    elsif http_status == 400 && body == 'Parent Object is public, permission not required'
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: body)
    elsif http_status == 403
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: 'Too many pending requests')
    elsif http_status == 201 || http_status == 200
      redirect_to("/catalog/#{params[:oid]}/request_confirmation", notice: 'Your request has been submitted for review by Library staff')
    else
      redirect_to("/catalog/#{params[:oid]}/request_form", notice: "An error has occured.  Please try again later.")
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def permission_request_params
    params.require(:permission_request).permit(:oid, :user_sub, :user_email, :user_full_name, :user_note, :user_netid)
  end
end
