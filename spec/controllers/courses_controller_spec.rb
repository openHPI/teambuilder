require 'rails_helper'

RSpec.describe CoursesController, type: :controller do

  let!(:course) do
    Course.create(
      id: 'ae2bc52d-e51a-454d-b1da-6f8aa5b0ec89',
      name: 'Course 1',
      auth_key: 'abc',
      auth_secret: 'def',
      url: 'www',
      workflow_state: 'published'
    )
  end

  before do
    warden.set_user LtiUser.new(
      SecureRandom.uuid,
      {
        'roles' => 'teacher',
        'context_id' => course.id,
        'lis_outcome_service_url' => 'https://hpi.de/outcomes'
      }
    )
  end

  let(:params) { { id: course.id } }

  describe 'GET show' do
    subject { get :show, params: params }

    it { is_expected.to have_http_status 200 }
  end

  describe 'POST #team_action' do
    subject { post :team_action, params: params }

    context 'delete_empty_teams=true' do
      let(:params) { super().merge(delete_empty_teams: true) }

      before do
        create(:team, course: course)
        create(:team, course: course)
        create(:team, :with_members, course: course)
      end

      it 'deletes empty teams' do
        expect { subject }.to change { course.reload.teams.size }.from(3).to(1)
      end
    end
  end

end
