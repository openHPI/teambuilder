require 'rails_helper'

RSpec.describe LtiController, type: :controller do

  let(:course_id) { 'ae2bc52d-e51a-454d-b1da-6f8aa5b0ec89' }
  let(:course_params) {
    {
      id: course_id,
      name: 'Course 1',
      auth_key: 'abc',
      auth_secret: 'def',
      url: 'www',
      workflow_state: 'published'
    }
  }

  let(:lti_params) {
    {
      context_id: course_id,
      user_id: '12345',
      launch_presentation_return_url: 'foobar',
      lis_person_contact_email_primary: 'some@email.com',
      lis_result_sourcedid: nil,
      roles: 'student'
    }.stringify_keys
  }

  describe 'POST launch' do
    subject { post :launch, params: params }
    let(:params) { {} }

    context 'invalid request' do
      it { is_expected.to have_http_status 403 }
    end

    context 'signed request' do
      before do
        Course.create course_params
        allow_any_instance_of(IMS::LTI::Services::MessageAuthenticator).to receive(:valid_signature?).and_return(true)
      end

      context 'without enough LTI parameters' do
        it { is_expected.to have_http_status 403 }
      end

      context 'with valid LTI launch data' do
        let(:params) { lti_params }
        let(:location) { new_course_enrollments_path(course_params[:id]) }

        it { is_expected.to redirect_to location }

        it 'logs the user in' do
          subject
          expect(controller.current_user).to be_a(LtiUser)
        end
      end
    end

  end

  describe 'GET return_via_lti' do
    subject { get :back, params: params }
    let(:params) { {} }

    before do
      Course.create course_params
      warden.set_user LtiUser.new('12345', lti_params)
    end

    context 'as a guest' do
      before do
        warden.logout
      end

      it { is_expected.to have_http_status 403 }
    end

    context 'without a valid enrollment' do
      it { skip 'this should return 400' }
    end

    context 'valid request' do
      it { is_expected.to have_http_status 200 }

      it 'empties the session' do
        expect{subject}.to change{ session.empty? }.from(false).to(true)
      end

      context 'with LTI outcome service' do
        let(:lti_params) {
          super().merge(
            'lis_outcome_service_url' => 'barbaz',
            'lis_result_sourcedid' => 'bazbam'
          )
        }

        it 'sends a positive score to the LTI outcome service' do
          expect_any_instance_of(OAuth::AccessToken).to receive(:post)
          subject
        end
      end
    end

  end

end
