class LtiStrategy < Warden::Strategies::Base

  LTI_REQUIRED_PARAMS = %w(
    user_id
    roles
    context_id
    lis_person_contact_email_primary
    launch_presentation_return_url
    lis_result_sourcedid
  ).freeze

  LTI_SAVE_PARAMS = %w(
    lis_outcome_service_url
    lis_person_name_full
    lis_person_name_given
    lis_person_name_family
  ).freeze

  def authenticate!
    if enough_for_lti? and authenticator.valid_signature?
      success! LtiUser.new(params['user_id'], params.slice(*save_params))
    else
      fail! 'Could not login via LTI'
    end
  end

  private

  def authenticator
    IMS::LTI::Services::MessageAuthenticator.new(
      request.url, request.request_parameters, course.oauth_credentials[:secret]
    )
  end

  def enough_for_lti?
    LTI_REQUIRED_PARAMS.all? { |key| params.key? key }
  end

  def save_params
    LTI_REQUIRED_PARAMS + LTI_SAVE_PARAMS
  end

  def course
    @course ||= Course.find_by_id(params['context_id']) || fail_hard
  end

  def fail_hard
    fail!('This course is not configured for LTI')
    throw :warden, type: :lti
  end

end
