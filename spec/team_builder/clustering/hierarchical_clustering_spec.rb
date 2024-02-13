require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping::Utils::Clustering::HierarchicalClustering do
  let(:clustering) do
    described_class.new features: features, min_size: 2, max_size: max_size
  end

  describe '(clustering)' do
    let(:result) { clustering.cluster_participants cluster }
    let(:participants_count) do
      amount = 0
      result.each do |cluster|
        amount += cluster.items.length
      end
      amount
    end

    context 'with 8 participants' do
      let(:cluster) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new items, {features: features} }
      let(:items) { CourseFactory.age_items({features: features}) }
      let(:features) do
        TeamBuilder::FeatureCollection.new [TeamBuilder::CourseFeatures::Age.new(1.0, 1.0, 'similar')]
      end

      context 'max_size is 8' do
        let(:max_size) { 8 }

        describe 'cluster length' do
          subject { result[0].items.length }

          it { is_expected.to eq 8 }
        end

        describe 'participants count' do
          subject { participants_count }

          it { is_expected.to eq 8 }
        end

        describe 'participants' do
          subject { result[0].items }

          it { is_expected.to match_array items }
        end
      end

      context 'max_size is 4' do
        let(:max_size) { 4 }

        describe 'cluster length' do
          subject { result[0].items.length }

          it { is_expected.to be <= 4 }
        end

        describe 'participants count' do
          subject { participants_count }

          it { is_expected.to eq 8 }
        end

        describe 'participants' do
          subject { result[0].items }

          it { is_expected.to match_array items.values_at(0, 2, 4, 6) }
        end
      end
    end
  end
end
