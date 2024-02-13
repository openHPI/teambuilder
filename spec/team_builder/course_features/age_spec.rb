require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::Age do

  describe "Age distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::Age.new 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { ["20-29"] }
      let(:values2) { ["20-29"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 0.0 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 1000.0 }
      end
    end
    context "Cluster distance" do
      let(:values1) { ["20-29", "30-39"] }
      let(:values2) { ["20-29", "40-49"] }
      context "similar" do
        let(:diversity) { 'similar' }
        it { is_expected.to eq 0.5/6*1000 }
      end
      context "diverse" do
        let(:diversity) { 'diverse' }
        it { is_expected.to eq 1000-0.5/6*1000 }
      end
    end
  end
end
