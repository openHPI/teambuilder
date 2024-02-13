require 'rails_helper'

feature 'New enrollment page' do
  given(:course_id) { 'ae2bc52d-e51a-454d-b1da-6f8aa5b0ec89' }
  given(:course_params) {
    {
      id: course_id,
      name: 'Course 1',
      auth_key: 'abc',
      auth_secret: 'def',
      url: 'www',
      workflow_state: 'published'
    }
  }

  given(:user_id) { 'ae2bc52d-e51a-454d-b1da-6f8aa5f0ec89' }

  given(:course) { Course.create course_params }
  given(:user) do
    LtiUser.new(user_id, {
      'context_id' => course_id,
      'user_id' => user_id,
      'launch_presentation_return_url' => 'foobar',
      'lis_person_contact_email_primary' => 'some@email.com',
      'lis_result_sourcedid' => nil,
      'lis_outcome_service_url' => nil,
      'roles' => 'student'
    })
  end

  background { login_as user }

  scenario 'Enrolling as user' do
    visit new_course_enrollments_path(course)
    expect(page).to have_selector(:link_or_button, 'Submit')

    select 'GMT-10:00 (Hawaii)', from: 'time_zone'
    expect { click_on 'Submit' }.to change { Enrollment.count }.from(0).to(1)

    enrollment = Enrollment.last
    expect(enrollment.course).to eq course
    expect(enrollment.user_id).to eq user.id
  end

  context 'for an already registered enrollment' do
    background do
      visit new_course_enrollments_path(course)
      select 'GMT-10:00 (Hawaii)', from: 'time_zone'
      click_on 'Submit'
      # The redirect per default logs the user out so we're login him back in to test the new page
      login_as user
    end

    scenario 'Canceling participation' do
      visit new_course_enrollments_path(course)
      expect(page).to have_selector(:link_or_button, 'Cancel Participation')

      # This only works with js and selenium enabled, but it's not that important anyways
      # find(".reset").hover
      # expect(page).to have_content("Cancel application for the team work. You wont be assigned to any team.")

      expect { click_on 'Cancel Participation' }.to change { Enrollment.count }.by -1

      expect(page).to have_content('Thank you for letting us know that you cannot participate in the team work.')
    end
  end

  after { Warden.test_reset! }
end
