class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_action :authenticate_user!
  after_action :allow_iframe

  # Include our routing configuration
  include Routing

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def root
    render 'welcome'
  end


  ## AUTHENTICATION

  helper_method :warden, :signed_in?, :current_user

  def signed_in?
    !current_user.nil?
  end

  def current_user
    warden.user || GuestUser.new
  end

  def warden
    request.env['warden']
  end

  def authenticate!
    warden.authenticate!
  end

  def authenticate_lti!
    warden.authenticate! :lti, type: 'lti'
  end

  def authenticate_admin!
    warden.authenticate! :password, type: 'admin'
  end

end
