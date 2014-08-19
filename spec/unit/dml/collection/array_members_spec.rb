require 'spec_helper'

describe Dml::Collection::ArrayMembers do
  let(:instance) { described_class.new(data) }

  include_context 'Dml::Collection'

  context 'when array of hashes' do
    let(:instance) { described_class.new(data) }

    let(:john) { data[0] }
    let(:july) { data[1] }
    let(:josh) { data[2] }

    it_behaves_like 'Dml::Collection methods'
    it_behaves_like 'Dml::Collection::Members iterators'
  end

  context 'when array of objects' do
    let(:instance) { described_class.new(objects) }

    let(:objects) do
      data.map { |member| entity.new(member) }
    end

    let(:john) { entity.new(data[0]) }
    let(:july) { entity.new(data[1]) }
    let(:josh) { entity.new(data[2]) }

    it_behaves_like 'Dml::Collection methods'
    it_behaves_like 'Dml::Collection iterators'
  end
end
