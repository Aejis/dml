require 'spec_helper'

describe Dml::Collection do
  let(:instance) { described_class.new(collection, entity) }

  let(:john) { entity.new(data[0]) }
  let(:july) { entity.new(data[1]) }
  let(:josh) { entity.new(data[2]) }

  context 'when array' do
    let(:collection) { data }

    include_context 'Dml::Collection'

    it_behaves_like 'Dml::Collection methods'
    it_behaves_like 'Dml::Collection iterators'
  end

  context 'when dataset' do
    let(:collection) { DB[:test_users].order(:id) }

    include_context 'Dml::Collection from database'

    it_behaves_like 'Dml::Collection methods'
    it_behaves_like 'Dml::Collection iterators'
  end

end
