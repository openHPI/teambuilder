require 'spec_helper'

require 'team_builder/feature_collection'
require 'team_builder/course_features'

RSpec.describe TeamBuilder::FeatureCollection do

  subject { described_class.new features }
  let(:features) { [] }

  describe '#sort_options' do
    subject { super().sort_options }

    it { is_expected.to be_an Hash }
    it { is_expected.to be_empty }

    context 'with language' do
      let(:features) { super().push TeamBuilder::CourseFeatures::LanguageTeams.new('en') }

      it { expect(subject['language']).to respond_to :sort }
    end
  end

  describe 'enabling features for grouping' do
    let(:features) do
      [
        TeamBuilder::CourseFeatures::LanguageTeams.new('en'),
        TeamBuilder::CourseFeatures::PreferredTasks.new(%w[woodchucking jumping]),
        TeamBuilder::CourseFeatures::Timezone.new,
      ]
    end

    it 'is disabled by default' do
      collection = described_class.new features

      expect(collection.grouping_enabled?('language_teams')).to eq false
      expect(collection.grouping_enabled?('preferred_tasks')).to eq false
      expect(collection.grouping_enabled?('timezone')).to eq false
    end

    it 'can be done through the constructor' do
      collection = described_class.new features, %w[preferred_tasks timezone]

      expect(collection.grouping_enabled?('language_teams')).to eq false
      expect(collection.grouping_enabled?('preferred_tasks')).to eq true
      expect(collection.grouping_enabled?('timezone')).to eq true
    end

    it 'can create a new collection containing only the features enabled for grouping' do
      collection = described_class.new features, %w[preferred_tasks timezone]
      expect(collection.count).to eq 3

      enabled = collection.only_grouping_enabled

      expect(enabled).to_not eq collection
      expect(enabled.count).to eq 2
      expect(enabled.map(&:type)).to match_array %w[preferred_tasks timezone]
    end

    it 'can create a new collection with specific features enabled and configured' do
      collection = described_class.new features

      new_collection = collection.with_group_settings(%w[preferred_tasks], features: {})

      expect(new_collection).to_not eq collection
      expect(new_collection.count).to eq 3
      expect(new_collection.grouping_enabled?('language_teams')).to eq false
      expect(new_collection.grouping_enabled?('preferred_tasks')).to eq true
      expect(new_collection.grouping_enabled?('timezone')).to eq true # timezone is always enabled for grouping
    end
  end

end
