class LtiUser

  def initialize(id, lti_params)
    @id = id
    @lti = lti_params

    @teacher = %w(instructor administrator).any? {|role| roles.include?(role) }
  end

  def guest?
    false
  end

  def admin?
    false
  end

  def course_admin?
    @teacher
  end

  def can_enroll?(course)
    can_submit? && course.id == @lti['context_id']
  end

  def can_administer?(course)
    @teacher && can_enroll?(course)
  end

  def can_submit?
    @lti.has_key? 'lis_outcome_service_url'
  end

  attr_reader :id

  def name
    if @lti['lis_person_name_full']
      @lti['lis_person_name_full']
    else
      "#{@lti['lis_person_name_given']} #{@lti['lis_person_name_family']}"
    end
  end

  def email
    @lti['lis_person_contact_email_primary']
  end

  def outcome_service?
    @lti['lis_outcome_service_url'] && @lti['lis_result_sourcedid']
  end

  def replace_outcome!(score)
    credentials = course.oauth_credentials
    consumer = OAuth::Consumer.new(credentials[:key], credentials[:secret])
    token = OAuth::AccessToken.new(consumer)
    token.post(
      @lti['lis_outcome_service_url'],
      outcome_xml(score),
      'Content-Type' => 'application/xml'
    )
  end

  def serialize
    {
      type: 'lti',
      props: {
        id: @id,
        lti: @lti
      }
    }
  end

  def self.from_serialized(props)
    new props['id'], props['lti']
  end

  def enrollment(course)
    course.enrollments.find_by(user_id: id)
  end

  private

  def outcome_xml(score)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.instruct!

    builder.imsx_POXEnvelopeRequest('xmlns' => 'http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0') do |env|
      env.imsx_POXHeader do |header|
        header.imsx_POXRequestHeaderInfo do |info|
          info.imsx_version 'V1.0'
          info.imsx_messageIdentifier SecureRandom.uuid
        end
      end
      env.imsx_POXBody do |body|
        body.tag!('replaceResultRequest') do |request|
          request.resultRecord do |record|
            record.sourcedGUID do |guid|
              guid.sourcedId @lti['lis_result_sourcedid']
            end
            record.result do |node|
              node.resultScore do |res_score|
                res_score.language 'en'
                res_score.textString score.to_s
              end
            end
          end
        end
      end
    end
  end

  def course
    Course.find @lti['context_id']
  end

  def roles
    @roles ||= @lti['roles'].split(',').map(&:downcase)
  end

end
