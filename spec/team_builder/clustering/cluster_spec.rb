require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping::Utils::Clustering::Cluster do
  let(:features) { TeamBuilder::FeatureCollection.new [TeamBuilder::CourseFeatures::Age.new(1.0, 1.0, 'similar')] }
  let(:cluster) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new(items, { features: features }) }
  let(:items) { [item1] }
  let(:item1) { CourseFactory.new_item({ features: features }, age: '1-19') }

  describe "Creating cluster" do
    subject { cluster }
    it { is_expected.to be }
    it "should have correct values added" do
      expect(cluster.value.raw_values["group_by_age"]).to contain_exactly '1-19'
    end
  end

  describe "Adding an item to cluster" do
    before do
      cluster.add_item item2
    end
    let(:item2) { CourseFactory.new_item({ features: features }, age: "1-19") }
    subject { cluster.items }
    it "should have 2 items" do
      expect(subject.length).to eq 2
    end
    it { is_expected.to contain_exactly item1, item2 }
  end

  describe "Removing an item from cluster" do
    before do
      cluster.remove_item item1
    end
    subject { cluster }
    it "should have no items" do
      expect(subject.items.length).to eq 0
    end
    it "should not have any values" do
      expect(subject.value.raw_values["group_by_age"].length).to eq 0
    end
  end

  describe "Value of cluster without the initial item" do
    let(:value) { cluster.value_without item1 }
    subject { value.raw_values["group_by_age"] }
    it { is_expected.to eq([]) }
    it "original value should be the same" do
      expect(cluster.value.raw_values["group_by_age"]).to eq(['1-19'])
    end
  end

  describe "Merging cluster of 2 clusters" do
    let(:cluster1) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new(items1, { features: features }) }
    let(:cluster2) { TeamBuilder::Grouping::Utils::Clustering::Cluster.new(items2, { features: features }) }
    let(:merged_cluster) { TeamBuilder::Grouping::Utils::Clustering::Cluster::merge_cluster cluster1, cluster2 }
    subject { merged_cluster }

    context "with 1 item each" do
      let(:items1) { [CourseFactory.new_item({ features: features }, age: '1-19')] }
      let(:items2) { [CourseFactory.new_item({ features: features }, age: '1-19')] }
      it { is_expected.to be }
      it "should have both clusters items" do
        expect(merged_cluster.items).to eq items1 + items2
      end
      describe "Cluster value" do
        subject { merged_cluster.value.raw_values["group_by_age"] }
        it "should have length 2" do
          expect(subject.length).to eq 2
        end
        it { is_expected.to contain_exactly "1-19", "1-19" }
      end
    end

    context "with 2 items each" do
      let(:items1) { [CourseFactory.new_item({ features: features }, age: '1-19'),
                      CourseFactory.new_item({ features: features }, age: '20-29')] }
      let(:items2) { [CourseFactory.new_item({ features: features }, age: '1-19'),
                      CourseFactory.new_item({ features: features }, age: '30-39')] }

      it { is_expected.to be }
      it "should have both clusters items" do
        expect(merged_cluster.items).to eq items1 + items2
      end

      describe "Cluster value" do
        subject { merged_cluster.value.raw_values["group_by_age"] }
        it "should have length 4" do
          expect(subject.length).to eq 4
        end
        it { is_expected.to contain_exactly "1-19", "1-19", "20-29", "30-39" }
      end
    end

  end
end
