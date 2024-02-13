require 'rails_helper'

feature 'Course teams page' do
  given(:user_id) { 'ae2bc52d-e51a-454d-b1da-6f8aa5f0ec89' }
  given(:course) { create :course, :with_teams }
  given(:user) do
    LtiUser.new(user_id, {
      'context_id' => course.id,
      'user_id' => user_id,
      'launch_presentation_return_url' => 'foobar',
      'lis_person_contact_email_primary' => 'some@email.com',
      'lis_result_sourcedid' => nil,
      'lis_outcome_service_url' => nil,
      'roles' => 'teacher'
    })
  end

  scenario 'Visiting as teacher' do
    login_as user
    visit teams_course_path(course)

    expect(page).to have_content('Team 1')
    expect(page).to have_content('Team 2')

    expect(page).to have_selector(:link_or_button, 'Back to team settings')
  end

  scenario 'Deleting empty teams' do
    login_as user
    visit teams_course_path(course)

    expect(page).to have_selector(:link_or_button, 'Delete empty teams')

    click_on 'Delete empty teams'
    expect(page).to have_content('Team 2')
    expect(page).to_not have_content('Team 1')
  end
end
