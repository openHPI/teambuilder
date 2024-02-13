require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::Gender do
  describe "Gender distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::Gender.new 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { ["male"] }
      let(:values2) { ["female"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 1000.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 0.0 }
      end
    end
    context "Cluster distance" do
      let(:values1) { ["male", "male"] }
      let(:values2) { ["female", "female"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 1000.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 0.0 }
      end
    end
  end
end
