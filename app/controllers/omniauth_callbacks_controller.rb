# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  prepend_before_action { request.env["devise.skip_timeout"] = true }

  def auth
    request.env['omniauth.auth']
  end

  def openid_connect
    netid = auth.extra.raw_info.identities.pluck(:userId)
    sub = auth.extra.raw_info.sub
    @user = User.where(provider: auth.provider, uid: auth.uid, sub: sub, netid: netid).first
    if @user.nil?
      @user = User.create(
          provider: auth.provider,
          uid: auth.uid,
          sub: sub,
          netid: netid,
          email: auth.info.email
        )
    end

    if @user
      sign_in @user, event: :authentication # this will throw if @user is not activated
      redirect_to request.env['omniauth.origin'] || root_path
      set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
    else
      redirect_to root_path
    end
  end

  protected

  def after_omniauth_failure_path_for(_resource)
    root_path
  end
end