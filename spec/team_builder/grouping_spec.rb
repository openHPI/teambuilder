require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping do
  let(:course) { CourseFactory.generate_course }
  let(:teams) { TeamBuilder::Grouping::start! course.enrollments, features, opts }

  shared_examples 'a correctly created course' do
    subject { course }

    it 'has correct name' do
      expect(subject.name).to eq 'test course'
    end

    it 'enrollment 1 exists' do
      expect(subject.enrollments[0]).to be
    end

    it 'enrollment 1 has correct name' do
      expect(subject.enrollments[0].name).to eq 'A'
    end

    it 'enrollment 2 exists' do
      expect(subject.enrollments[1]).to be
    end
  end

  describe 'randomize' do
    before { CourseFactory.add_enrollments_to course }

    it_behaves_like 'a correctly created course'

    describe 'Teams created' do
      let(:teams) { TeamBuilder::Grouping.start! course.enrollments, features, opts }
      let(:features) { { max_size: 4 } }
      let(:member_names) { teams.first.members.map(&:name) }

      subject { teams }

      shared_examples 'team check' do
        it { is_expected.to be }

        it 'has the correct teamsize' do
          teams.each do |team|
            expect(team.members.length).to be <= features[:max_size]
          end
        end

        it 'includes the correct number of participants' do
          count = teams.map {|team| team.members.length}.sum
          count += course.orphan_team.members.length
          expect(count).to be == opts[:max_participants]
        end
      end

      context 'with randomize and score enabled' do
        let(:opts) do
          {
            randomize: true,
            max_participants: 4,
            min_score: 96
          }
        end

        it_behaves_like 'team check'

        describe 'member names' do
          subject { member_names }

          it { is_expected.to include 'A' }
          it { is_expected.to include 'G' }
          it { is_expected.to_not include 'C' }
          it { is_expected.to_not include 'E' }
          it { is_expected.to include('B', 'F').or include('B', 'D').or include('D', 'F') }
        end
      end

      context 'with randomize disabled but score enabled' do
        let(:opts) do
          {
            randomize: false,
            max_participants: 4,
            min_score: 96
          }
        end

        it_behaves_like 'team check'

        it 'selects the correct participants' do
          members = subject.first.members
          expect(members[0].name).to eq 'A'
          expect(members[1].name).to eq 'G'
          expect(members[2].name).to eq 'B'
          expect(members[3].name).to eq 'D'
        end
      end

      context 'with randomize and score disabled' do
        let(:opts) do
          {
            randomize: false,
            max_participants: 4,
            min_score: false
          }
        end

        it_behaves_like 'team check'

        it 'selects the correct participants' do
          expect(member_names).to include 'A', 'B', 'C', 'D'
        end
      end

      context 'with randomize enabled but score disabled' do
        let(:opts) do
          {
            randomize: true,
            max_participants: 4,
            min_score: false
          }
        end

        it_behaves_like 'team check'

        it 'selects the correct participants' do
          expect(%w(A B C D E F G)).to include *member_names
        end
      end
    end
  end

  describe 'commitment' do
    before { CourseFactory.add_enrollments_with_commitment_to course }

    it_behaves_like 'a correctly created course'

    describe 'Teams created' do
      let(:features) do
        TeamBuilder::FeatureCollection.new(
          [
            TeamBuilder::CourseFeatures::Commitment.new('similar')
          ]
        ).with_group_settings(
          ['group_by_commitment'],
          features: {'group_by_commitment' => {diversity: 'similar'}}
        )
      end

      let(:opts) do
        {
          max_participants: 6,
          min_score: false,
          max_size: 3
        }
      end

      subject { teams }

      it { is_expected.to be }

      it 'has correct number of teams' do
        expect(subject.length).to be 3
      end

      it 'has correct members' do
        grouping_result = [
          subject[0].members.map(&:name),
          subject[1].members.map(&:name),
          subject[2].members.map(&:name)
        ]
        expect(grouping_result).to match_array [
          array_including('A', 'E'),
          array_including('B', 'D'),
          array_including('C', 'F')
        ]
      end

      describe 'orphans' do
        subject { course.orphan_team.members }

        it { is_expected.to be_empty }
      end
    end
  end

  describe 'age' do
    before { CourseFactory.add_enrollments_with_age_to course }

    it_behaves_like 'a correctly created course'

    describe 'Teams created' do
      let(:features) do
        TeamBuilder::FeatureCollection.new(
          [
            TeamBuilder::CourseFeatures::Timezone.new,
            TeamBuilder::CourseFeatures::Age.new('similar')
          ]
        ).with_group_settings(
          ['group_by_age'],
          features: {'group_by_age' => {diversity: 'similar'}}
        )
      end

      let (:opts) do
        {
          max_participants: 6,
          min_score: false,
          max_size: 3
        }
      end

      subject { teams }

      it { is_expected.to be }

      it 'has correct number of teams' do
        expect(subject.length).to be 2
      end

      it 'has correct members' do
        grouping_result = [
          subject[0].members.map(&:name),
          subject[1].members.map(&:name)
        ]
        expect(grouping_result).to match_array [
          array_including('A', 'C', 'E'),
          array_including('B', 'D', 'F')
        ]
      end

      describe 'orphans' do
        subject { course.orphan_team.members }

        it { is_expected.to be_empty }
      end
    end
  end
end
