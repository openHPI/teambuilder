require 'rails_helper'

RSpec.describe Enrollment, type: :model do

  let(:params) { {} }

  subject { Enrollment.new(params) }

  describe '#data' do
    subject { super().data }

    it { is_expected.to be_nil }

    context 'hash' do
      let(:params) { super().merge(data: {foo: 'bar', baz: 'bam'}) }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include('foo' => 'bar', 'baz' => 'bam') }
    end
  end

end
