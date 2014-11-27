require 'spec_helper'

describe Dml::Relation::DSL::BelongsToOne do
  let(:instance) { described_class.new(:users, :info) }

  let(:klass) { Dml::Relation::Associations::OneToOne }

  it_behaves_like 'dsl association'
end
