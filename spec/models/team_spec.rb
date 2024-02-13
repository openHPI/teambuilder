require 'rails_helper'

RSpec.describe Team, type: :model do

  subject { Team.new(params) }

  let(:params) { {course: course} }
  let!(:course) { create :course }

  describe 'validation' do
    it { is_expected.not_to be_valid }

    context 'with a name' do
      let(:params) { super().merge(name: 'Some team name') }

      it { is_expected.to be_valid }
    end
  end

end
