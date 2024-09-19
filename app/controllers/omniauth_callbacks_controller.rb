# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  prepend_before_action { request.env["devise.skip_timeout"] = true }

  def auth
    request.env['omniauth.auth']
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def openid_connect
    sub = auth.extra.raw_info.sub
    # Login for Yale users
    if auth.extra.raw_info.identities.present?
      yale_issuers = %w[https://auth.yale.edu/idp/shibboleth https://auth-test.yale.edu/idp/shibboleth]
      yale_identity = auth.extra.raw_info.identities.find { |i| yale_issuers.include?(i.issuer) }
      netid = yale_identity&.userId
      @user = User.where(provider: auth.provider, uid: auth.uid, sub: sub).first
      if @user.nil?
        @user = User.create(
            provider: auth.provider,
            uid: auth.uid,
            sub: sub,
            netid: netid,
            email: auth.info.email
          )
      end
      set_ai_session
    else
      # Login for non-yale users without a net_id
      @user = User.where(provider: auth.provider, uid: auth.uid, sub: sub).first
      if @user.nil?
        @user = User.create(
            provider: auth.provider,
            uid: auth.uid,
            sub: sub,
            email: auth.info.email
          )
      end
    end

    if @user
      sign_in @user, event: :authentication # this will throw if @user is not activated
      redirect_to request.env['omniauth.origin'] || root_path
      set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
    else
      redirect_to root_path
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  protected

  def set_ai_session
    # set flag in session for AI-authorized users
    groups = auth.extra.raw_info['cognito:groups']
    ai_group = groups.find { |g| 'ai-user' == g } if groups
    session[:show_ai_option] = true if ai_group
  end

  def after_omniauth_failure_path_for(_resource)
    root_path
  end
end
