require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping::Utils::Clustering::KmeansClustering do
  let(:clustering) { TeamBuilder::Grouping::Utils::Clustering::KmeansClustering.new k, 100, { features: features }, even }

  describe "Clustering" do
    let(:k) { 2 }
    let(:cluster) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new items, { features: features } }
    let(:features) { TeamBuilder::FeatureCollection.new ([TeamBuilder::CourseFeatures::Age.new(1.0, 1.0, 'similar')]) }
    context "With 8 Participants and K=2" do
      let(:even) { false }
      let(:result) { clustering.cluster_participants cluster }
      let(:items) { CourseFactory.age_items({ features: features }) }
      describe "Amount of resulting clusters" do
        subject { result.length }
        it { is_expected.to eq 2 }
      end
      describe "cluster 1 content" do
        subject { result[0].items }
        it " should contain 4 items" do
          expect(subject.length).to eq 4
        end
        it { is_expected.to contain_exactly(items[0], items[2], items[4], items[6]).or (contain_exactly(items[1], items[3], items[5], items[7])) }
      end
      describe "cluster 2 content" do
        subject { result[1].items }
        it " should contain 4 items" do
          expect(subject.length).to eq 4
        end
        it { is_expected.to contain_exactly(*(items - result[0].items)) }
      end
    end
    describe "with evenly sized clusters" do
      let(:even) { true }
      let(:result) { clustering.cluster_participants cluster }
      let(:items) { CourseFactory.age_items({ features: features }, 14, 3) }

      describe "amount of generated clusters" do
        subject { result.length }
        it { is_expected.to eq 2 }
      end

      describe "size of cluster" do
        subject { result }
        it "1 should roughly contain 7 participants" do
          expect(result[0].size).to be_within(1).of 7
        end
        it "2 should roughly contain 7 participants" do
          expect(result[0].size).to be_within(1).of 7
        end
        it "adds up to 14 participants" do
          expect(result[0].size + result[1].size).to eq 14
        end
      end

      describe "cluster statistics" do
        subject { result }

        it "should be 'good enough'" do
          # This test is pretty bad right now, but I haven't figured out a good way to test the validity
          # of a good cluster result yet
          expect(TeamBuilder::Grouping::DistanceAlgorithm.maximum_distance_in_cluster(result[0]) +
                   TeamBuilder::Grouping::DistanceAlgorithm.maximum_distance_in_cluster(result[1])).to be <= 500
        end

      end

    end
  end
end
