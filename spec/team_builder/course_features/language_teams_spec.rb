require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::LanguageTeams do

  describe "Language distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::LanguageTeams.new 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { ["German"] }
      let(:values2) { ["English"] }
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
      let(:values1) { ["English", "German"] }
      let(:values2) { ["English", "Spanish"] }
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
