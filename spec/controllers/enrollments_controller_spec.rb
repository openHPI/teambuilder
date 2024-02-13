require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do

  let(:params) { { course_id: course_id } }
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
      'roles' => 'student',
      'context_id' => course_id,
      'lis_outcome_service_url' => 'https://hpi.de/outcomes'
    }
  }
  let(:user) { LtiUser.new('ae2bc52d-e51a-454d-b1da-6f8aa5f0ec89', lti_params) }

  let!(:course) { Course.create(course_params) }
  before do
    warden.set_user user
  end

  describe 'GET new' do
    subject { get :new, params: params }

    context 'guest user' do
      before do
        warden.logout
      end

      it { is_expected.to have_http_status 403 }
    end

    context 'unknown course' do
      let(:params) { super().merge(course_id: 'unknown') }

      it { is_expected.to have_http_status 404 }
      it { is_expected.to render_template 'course_not_found' }
    end

    context 'known course with unpublished settings' do
      let(:course_params) { super().merge(workflow_state: 'new') }

      it { is_expected.to have_http_status 409 }
      it { is_expected.to render_template 'not_published' }
    end

    context 'known course with exported teams' do
      let(:course_params) { super().merge(workflow_state: 'finished') }

      it { is_expected.to have_http_status 410 }
      it { is_expected.to render_template 'finished' }
    end

    context 'known course with published settings' do
      it { is_expected.to have_http_status 200 }
      it { is_expected.to render_template 'new' }
    end
  end

  describe 'DELETE destroy' do
    let(:params) { super().merge(id: user.id) }
    subject { delete :destroy, params: params }
    let!(:enrollment) { Enrollment.create(user_id: user.id, course_id: course.id) }

    context 'valid submission' do
      it { is_expected.to have_http_status 302 }
      it { expect { subject }.to change { Enrollment.count }.by(-1) }
    end

    context 'grouping already started' do
      let(:course_params) { super().merge(workflow_state: 'finished') }

      it { is_expected.to render_template 'finished' }
      it { is_expected.to have_http_status 410 }
    end

    context 'enrollment does not exist' do
      let(:course2_id) { 'ae2bc52d-e51a-454d-b1da-6f8aa5b1ec99' }
      let!(:course2) { Course.create(course_params.merge(id: course2_id)) }
      let(:params) { super().merge(course_id: course2_id) }

      it { is_expected.to_not have_http_status 404 }
      it { expect { subject }.to change { Enrollment.count }.by(0) }

    end
  end

  describe 'POST new' do
    let(:params) { super().merge(time_zone: '0') }
    subject { post :create, params: params }

    context 'valid submission' do
      it { is_expected.to have_http_status 302 }
      it { expect { subject }.to change { Enrollment.count }.by(1) }
    end

    context 'without a LTI outcome service URL' do
      let(:lti_params) { super().except('lis_outcome_service_url') }

      it { is_expected.to have_http_status :gone }
      it { is_expected.to render_template 'finished' }
    end
  end

end
