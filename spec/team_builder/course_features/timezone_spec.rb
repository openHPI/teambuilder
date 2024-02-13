require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::Timezone do

  describe "Timezone distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::Timezone.new 'same_timezone', 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { [0] }
      let(:values2) { [7200] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to be_within(0.00001).of 1.0/6.0*1000 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to be_within(0.00001).of 5.0/6.0*1000 }
      end
    end
    context "Cluster distance" do
      let(:values1) { [3600, 7200] }
      let(:values2) { [10800, 10800] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 125.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 875.0 }
      end
    end
  end
end
