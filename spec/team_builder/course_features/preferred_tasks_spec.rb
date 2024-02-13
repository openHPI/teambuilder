require 'spec_helper'

require 'team_builder/course_features'

RSpec.describe TeamBuilder::CourseFeatures::PreferredTasks do

  let(:tasks) {
    %w(task1 task2 task3)
  }

  let(:bucket_struct) { Struct.new(:data) }
  let(:buckets) {
    [
      {'preferred_task' => 0},
      {'preferred_task' => 1},
      {'preferred_task' => 1},
      {'preferred_task' => 1},
      {'preferred_task' => 2},
      {'preferred_task' => 2},
      {'preferred_task' => 2},
      {'preferred_task' => 2},
      {'preferred_task' => 2},
    ].map { |row|
      bucket_struct.new(row)
    }
  }

  subject { described_class.new tasks }

  describe '#bucketize' do
    subject { super().bucketize buckets }

    it { is_expected.to be_an(Array) }
    it { expect(subject.length).to eq(3) }
    it { expect(subject[0].map(&:data).map {|d| d['preferred_task'] }).to eq [0]}
    it { expect(subject[1].map(&:data).map {|d| d['preferred_task'] }).to eq [1, 1, 1]}
    it { expect(subject[2].map(&:data).map {|d| d['preferred_task'] }).to eq [2, 2, 2, 2, 2]}
  end

  describe "Preferred tasks distance calculation" do

    let(:feature) { TeamBuilder::CourseFeatures::PreferredTasks.new [1,2,3], 1.0, 1.0, diversity }
    let(:distance) { feature.distance_between(values1, values2) }
    subject { distance }
    describe "Item distance" do
      let(:values1) { [1] }
      let(:values2) { [2] }
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
      let(:values1) { [1, 2] }
      let(:values2) { [2, 3] }
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

