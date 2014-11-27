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

  describe '#initialize' do
    context 'when target dependency is not set' do
      let(:relations) do
        [
          instance_double('Dml::Relation', name: :locations, dependencies: Set[:companies])
        ]
      end

      it 'should raise error if relation was not defined' do
        expect { instance }.to raise_error(
          Dml::Relation::UndefinedDependencyError,
          'relation `companies` does not specified in relation list'
        )
      end
    end
  end

end
