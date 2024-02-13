require 'rails_helper'

RSpec.describe Course, type: :model do

  let(:params) { { platform_id: 'dummy' } }
  let(:course) { Course.new params }
  let(:new_course) {course}
  let(:published_course) { Course.new params.merge(workflow_state: 'published') }
  let(:finished_course) { Course.new params.merge(workflow_state: 'finished') }
  let(:copied_course) {Course.new params.merge(workflow_state: 'copied')}

  subject { course }

  describe 'validation' do
    it { is_expected.to be_valid }
  end

  describe 'export to CSV' do
    subject { course.teams_as_csv }
    let(:course) { create :course, :with_teams }

    it 'serializes all team members in CSV format' do
      is_expected.to eq <<~END
        Team 2,asdf,,,0%,GMT-05:00
        Team 2,asdf,,,0%,GMT-05:00
      END
    end
  end

  describe 'copying course' do
    let(:params) { { platform_id: 'dummy', workflow_state: 'published'} }
    let(:team) {Team.new(name: "Team 1")}
    let(:enrollment) {Enrollment.new name: "test name"}
    let(:published_course) { course = Course.new params
      course.teams << team
      course.enrollments << enrollment
      course
    }
    subject{ published_course }
    context 'before copying' do
      it 'has 1 team' do
        expect(subject.teams.length).to eq 1
      end

      it 'has 1 enrollment' do
        expect(subject.enrollments.length).to eq 1
      end
    end

    context 'after copying' do
      subject{ super().copy 'new_name' }
      it 'has 0 teams' do
        expect(subject.teams.length).to eq 0
      end

      describe 'enrollments' do
        subject{super().enrollments}
        it 'has 1 enrollment' do
          expect(subject.length).to eq 1
        end

        it 'is has the same attributes as the original enrollment' do
          expect(subject[0].name).to eq enrollment.name
        end

        it 'is not identical to the original enrollment' do
          expect(subject[0]).to_not eq enrollment
        end
      end
    end
  end

  shared_examples 'a workflow ability' do |with_responses: {new: false, published: false, finished: false, copied: false}|
    context 'new' do
      it{ is_expected.to be with_responses[:new] }
    end

    context 'after publication' do
      let(:course){published_course}
      it{ is_expected.to be with_responses[:published]}
    end

    context 'when finished' do
      let(:course){ finished_course }
      it{ is_expected.to be with_responses[:finished]}
    end

    context 'after copying' do
      let(:course) {copied_course}
      it{ is_expected.to be with_responses[:copied]}
    end

  end

  describe 'states' do
    describe '#new?' do
      subject { super().new? }

      it { is_expected.to be true }

      context 'after publication' do
        let(:course) { published_course }

        it { is_expected.to be false }
      end
    end

    describe '#published?' do
      subject { super().published? }

      it { is_expected.to be false }

      context 'after publication' do
        let(:course) { published_course }

        it { is_expected.to be true }
      end

      context 'after copying' do
        let(:course) {copied_course}

        it {is_expected.to be false}
      end

      context 'when finished' do
        let(:course) { finished_course }

        it { is_expected.to be false }
      end
    end

    describe '#copied?' do
      subject {super().copied?}
      it{ is_expected.to be false }

      context 'after copying' do
        let(:course) {copied_course}

        it {is_expected.to be true}
      end

      context 'after publication' do
        let(:course) { published_course }

        it { is_expected.to be false }
      end

      context 'when finished' do
        let(:course) { finished_course }

        it { is_expected.to be false }
      end
    end

    describe '#finished?' do
      subject { super().finished? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: false, copied: false, finished: true}
    end

    describe '#can_publish?' do
      subject { super().can_publish? }

      it_behaves_like 'a workflow ability', with_responses: {new: true, published: false, copied: false, finished: false}
    end

    describe '#can_create_collab_spaces?' do
      subject { super().can_create_collab_spaces? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: true, copied: false, finished: false}
    end

    describe '#can_clear_teams?' do
      subject { super().can_clear_teams? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: true, copied: true, finished: false}
    end

    describe '#can_manipulate_teams?' do
      subject { super().can_manipulate_teams? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: true, copied: true, finished: false}
    end

    describe '#can_export?' do
      subject { super().can_export? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: true, copied: true, finished: true}
    end

    describe '#can_copy?' do
      subject { super().can_copy? }

      it_behaves_like 'a workflow ability', with_responses: {new: false, published: true, copied: false, finished: true}
    end

    describe '#human_state' do
      subject { super().human_state }

      it { is_expected.to eq 'Not public' }

      context 'after publication' do
        let(:course) { published_course }

        it { is_expected.to eq 'Public 0 enrollments' }
      end

      context 'after copying' do
        let(:course) {copied_course}

        it {is_expected.to eq 'Copy 0 enrollments'}
      end

      context 'when finished' do
        let(:course) { finished_course }

        it { is_expected.to eq 'Teams transferred' }
      end
    end
  end

end
