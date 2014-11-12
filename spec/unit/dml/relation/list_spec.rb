require 'spec_helper'

describe Dml::Relation::List do
  let(:instance) { described_class.new(relations) }

  let(:relations) do
    [
      instance_double('Dml::Relation', name: :users, dependencies: Set[:companies, :locations]),
      instance_double('Dml::Relation', name: :companies, dependencies: Set[]),
      instance_double('Dml::Relation', name: :locations, dependencies: Set[:companies])
    ]
  end

  describe '#get' do
    subject { instance.get(rel_name) }

    let(:rel_name) { :users }

    it { expect(subject.name).to equal(rel_name) }
  end

  describe '#names' do
    subject { instance.names }

    it { expect(subject).to eql %i(companies locations users) }
  end

  describe '#to_a' do
    subject { instance.to_a }

    it { expect(subject.map(&:name)).to eql %i(companies locations users) }
  end

end
