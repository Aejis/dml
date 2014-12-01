require 'spec_helper'

describe Dml::Relation do
  let(:instance) { described_class.new(name, pkey, associations) }

  let(:name) { :users }
  let(:pkey) { :id }
  let(:associations) do
    {
      company: instance_double('Dml::Relation::Associations::ManyToOne', target_relation: :companies),
      profile: instance_double('Dml::Relation::Associations::OneToOne', target_relation: :profiles)
    }
  end

  describe '#name' do
    subject { instance.name }

    it { expect(subject).to equal(name) }
  end

  describe '#primary_key' do
    subject { instance.primary_key }

    it { expect(subject).to equal(pkey) }
  end

  describe '#associations' do
    subject { instance.associations }

    it { expect(subject).to match(associations) }
  end

  describe '#dependencies' do
    subject { instance.dependencies }

    context 'when associations was set' do
      it { expect(subject).to contain_exactly(:companies, :profiles) }
    end

    context 'when without associations' do
      let(:associations) { {} }

      it { expect(subject).to be_kind_of(Set) }
      it { expect(subject).to be_empty }
    end

  end

end
