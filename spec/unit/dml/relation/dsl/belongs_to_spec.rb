require 'spec_helper'

describe Dml::Relation::DSL::BelongsTo do
  let(:instance) { described_class.new(:users, :info) }

  let(:klass) { Dml::Relation::Associations::ManyToOne }

  it_behaves_like 'dsl association'
end
