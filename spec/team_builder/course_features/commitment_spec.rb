require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::Commitment do

  describe "Commitment distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::Commitment.new 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { ["1-2 Hours"] }
      let(:values2) { ["3-4 Hours"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 500.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 500.0 }
      end
    end
    context "Cluster distance" do
      let(:values1) { ["1-2 Hours", "1-2 Hours"] }
      let(:values2) { ["3-4 Hours", "5-6 Hours"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 750.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 250.0 }
      end
    end
  end
end
