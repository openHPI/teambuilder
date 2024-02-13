require 'json'

class EnrollmentsController < ApplicationController

  before_action :set_course
  before_action :ensure_course
  before_action :authenticate_lti!

  def new
    @errors = {}
    @enrollment = current_user.enrollment(@course)
    @previous = @enrollment ? @course.features.enrollment_data(@enrollment) : {}

    if @course.published?
      render
    elsif current_user.can_administer? @course
      @preview = true
      render
    elsif @course.finished?
      render_finished
    else
      render_not_published
    end
  end

  before_action :ensure_published_course, only: [:create]

  def create
    return render_finished unless current_user.can_submit?

    # Make sure we have valid data for all enabled features
    # If validation failed, we gather the various errors and pass them back to the view
    unless @course.features.valid?(params.to_unsafe_h)
      @errors = @course.features.errors

      return render action: 'new'
    end

    # Gather and save enrollment data
    @course.enrollments.find_or_initialize_by(
      user_id: current_user.id
    ).update(
      name: current_user.name,
      email: current_user.email,
      data: @course.features.data_from_params(params)
    )

    redirect_to return_via_lti_path
  end

  def destroy
    return render_finished unless current_user.can_enroll? @course
    return render_finished if @course.finished?

    current_user.enrollment(@course)&.destroy

    redirect_to return_via_lti_path(result: :deleted)
  end

  private

  def set_course
    @course = Course.find_by(id: params[:course_id])
  end

  def ensure_course
    render 'course_not_found', status: 404 unless @course
  end

  def ensure_published_course
    render_not_published unless @course.locked?
  end

  def render_not_published
    render 'not_published', status: 409
  end

  def render_finished
    render 'finished', status: 410
  end

end
