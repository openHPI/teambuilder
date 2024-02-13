require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping::DistanceAlgorithm do
  describe "Calculating distance statistics in cluster" do
    let(:features) { TeamBuilder::FeatureCollection.new [TeamBuilder::CourseFeatures::Age.new(1.0, 1.0, 'similar')] }
    let(:cluster) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new(items, { features: features }) }
    let(:items) { [item1] }
    let(:item1) { CourseFactory.new_item({ features: features }, age: '1-19') }
    let(:item2) { CourseFactory.new_item({ features: features }, age: '20-29') }
    describe "Average distance in cluster" do
      let(:average_distance) { TeamBuilder::Grouping::DistanceAlgorithm.average_distance_in_cluster cluster }
      subject { average_distance }
      context "1 item" do
        it { is_expected.to eq 0 }
      end
      context "2 items" do
        let(:items) { [item1, item2] }
        it { is_expected.to be_within(0.0001).of 166.666666 }
      end
    end

    describe "Maximum distance in cluster" do
      let(:maximum_distance) { TeamBuilder::Grouping::DistanceAlgorithm.maximum_distance_in_cluster cluster }
      subject { maximum_distance }
      context "1 item" do
        it { is_expected.to eq 0 }
      end

      context "2 items" do
        let(:items) {[item1, item2]}
        it{ is_expected.to be_within(0.0001).of 166.666666}
      end

    end
  end

end
