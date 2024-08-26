# frozen_string_literal: true

# def agreement_term
#   if current_user.nil?
#     redirect_to("#{ENV['BLACKLIGHT_HOST']}/catalog/#{params[:oid]}", notice: 'Please log in to request access to these materials.')
#     return false
#   end
#   url = URI.parse("#{ENV['MANAGEMENT_HOST']}/agreement_term")
#   req = Net::HTTP::Post.new(url.path)
#   req.set_form_data({
#                       'oid': params['oid'],
#                       'user_email': current_user.email,
#                       'user_netid': current_user.netid,
#                       'user_sub': current_user.sub,
#                       'user_full_name': "new",
#                       'permission_set_terms_id': params['permission_set_terms_id']
#                     })
#   req.add_field('Authorization', "Bearer #{ENV['OWP_AUTH_TOKEN']}")
#   con = Net::HTTP.new(url.host, url.port)
#   con.start { |http| http.request(req) }
#   handle_agreement_request_response(response.status, response.body)
# end

# def handle_agreement_request_response(http_status, body)
#   if http_status == 400 && body == 'Term not found.'
#     redirect_to("/catalog/#{params[:oid]}", notice: body)
#   elsif http_status == 400 && body == 'User not found.'
#     redirect_to("/catalog/#{params[:oid]}", notice: body)
#   elsif http_status == 401
#     render json: { error: 'unauthorized' }.to_json, status: :unauthorized
#   elsif http_status == 201 || http_status == 200
#     redirect_to("/catalog/#{params[:oid]}/request_form", notice: 'Terms Accepted.')
#   else
#     redirect_to("/catalog/#{params[:oid]}", notice: "An error has occured.  Please try again later.")
#   end
# end
