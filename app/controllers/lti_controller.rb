class LtiController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:launch]

  def launch
    # Make sure we're logged out so that authorization for this request
    # will not be omitted.
    warden.logout

    authenticate_lti!

    redirect_to new_course_enrollments_path params[:context_id]
  end

  before_action :authenticate_lti!, only: [:back]

  def back
    if current_user.outcome_service?
      current_user.replace_outcome! 1.0
    end
    warden.logout

    if params[:result] == 'deleted'
      render 'back_deleted'
    end
  end

end
