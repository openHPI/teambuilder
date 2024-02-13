require 'rails_helper'
require 'team_builder/course_factory'

RSpec.describe TeamBuilder::Grouping::Utils::Clustering::Value do
  let(:value) { TeamBuilder::Grouping::Utils::Clustering::Value.new({features: features}) }
  let(:features) { [TeamBuilder::CourseFeatures::Age.new(1.0, 1.0, 'similar')] }

  describe "Adding value" do

    before do
      value.add_value_of participants
    end
    context "One participant" do
      let(:participants) { [CourseFactory::new_enrollment(1, "A", 100, age: '1-19')] }

      subject { value }
      it "should have correct value" do
        expect(value.raw_values).to eq({"group_by_age" => ["1-19"]})
      end
    end

    context "Three participants" do
      let(:participants) { [CourseFactory::new_enrollment(1, "A", 100, age: '1-19'),
                            CourseFactory::new_enrollment(2, "B", 100, age: '20-29'),
                            CourseFactory::new_enrollment(3, "C", 100, age: '30-39')] }
      subject { value }
      it "should have correct values" do
        expect(value.raw_values).to eq({"group_by_age" => ["1-19", "20-29", "30-39"]})
      end
    end
  end

  describe "Removing value" do

    context "One participant added and one participant removed" do
      let(:participant) { CourseFactory::new_enrollment(1, "A", 100, age: '1-19') }
      before do
        value.raw_values = {"group_by_age" => ["1-19"]}
        value.remove_value_of participant
      end

      subject { value.raw_values }
      it { is_expected.to eq({"group_by_age" => []}) }
    end


  end
end
