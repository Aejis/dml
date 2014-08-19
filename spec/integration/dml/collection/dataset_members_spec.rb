require 'spec_helper'

describe Dml::Collection::DatasetMembers do
  let(:instance) { described_class.new(dataset) }
  let(:dataset)  { DB[:test_users].order(:id) }

  let(:john) { DB[:test_users][name: 'John'] }
  let(:july) { DB[:test_users][name: 'July'] }
  let(:josh) { DB[:test_users][name: 'Josh'] }

  include_context 'Dml::Collection from database'

  it_behaves_like 'Dml::Collection methods'
  it_behaves_like 'Dml::Collection::Members iterators'
end
