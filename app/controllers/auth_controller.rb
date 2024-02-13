class AuthController < ApplicationController

  skip_before_action :verify_authenticity_token, except: [:login]

  # This action is the target for all LTI authentication errors
  def fail_lti
    render plain: 'Invalid LTI request', status: 403
  end

  # This action is the target for all admin authentication errors
  def fail_admin
    # TODO: Get redirect target from env['warden.options']
    # {:type=>:admin, :action=>"unauthenticated", :message=>nil, :attempted_path=>"/courses"}
    login_form
  end

  def login_form
    render 'login_form'
  end

  def login
    warden.authenticate :password

    redirect_to courses_path
  end

  def logout
    warden.logout

    redirect_to root_path
  end

end
