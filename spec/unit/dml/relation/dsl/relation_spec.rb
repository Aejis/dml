require 'spec_helper'

describe Dml::Relation::DSL::Relation do
  let(:instance) { described_class.new(name) }
  let(:name) { :users }

  describe '#key' do
    before(:each) do
      allow(Dml::Relation).to receive(:new)
    end

    after(:each) do
      instance.relation
    end

    context 'by default' do
      it 'should be :id' do
        expect(Dml::Relation).to receive(:new).with(name, [:id], {})
      end
    end

    context 'when single' do
      before(:each) do
        instance.key(:uid)
      end

      it { expect(Dml::Relation).to receive(:new).with(name, [:uid], {}) }
    end

    context 'when composite' do
      before(:each) do
        instance.key(:id, :company)
      end

      it { expect(Dml::Relation).to receive(:new).with(name, [:id, :company], {}) }
    end
  end

  describe '#belongs_to' do
    let(:assoc)        { instance_double('Dml::Relation::Associations::ManyToOne') }
    let(:dsl)          { class_double('Dml::Relation::DSL::BelongsTo') }
    let(:dsl_instance) { instance_double('Dml::Relation::DSL::BelongsTo', association: assoc) }
    let(:blk)          { ->(foo) { foo } }

    before(:each) do
      allow(dsl).to receive(:new).and_return(dsl_instance)
      stub_const('Dml::Relation::DSL::BelongsTo', dsl)
    end

    it 'adds association to associations list' do
      instance.belongs_to(:user)
      expect(instance.associations).to include(user: assoc)
    end

    it 'sends name and params to DSL' do
      expect(dsl).to receive(:new).with(name, :user).and_yield(blk).and_return(dsl_instance)
      instance.belongs_to(:user, &blk)
    end
  end

  describe '#belongs_to_one' do
    let(:assoc)        { instance_double('Dml::Relation::Associations::OneToOne') }
    let(:dsl)          { class_double('Dml::Relation::DSL::BelongsToOne') }
    let(:dsl_instance) { instance_double('Dml::Relation::DSL::BelongsToOne', association: assoc) }
    let(:blk)          { ->(foo) { foo } }

    before(:each) do
      allow(dsl).to receive(:new).and_return(dsl_instance)
      stub_const('Dml::Relation::DSL::BelongsToOne', dsl)
    end

    it 'adds association to associations list' do
      instance.belongs_to_one(:profile)
      expect(instance.associations).to include(profile: assoc)
    end

    it 'sends name and params to DSL' do
      expect(dsl).to receive(:new).with(name, :profile).and_yield(blk).and_return(dsl_instance)
      instance.belongs_to_one(:profile, &blk)
    end
  end

  describe '#relation' do
    let(:relation_instance) { instance_double('Dml::Relation') }

    before(:each) do
      allow(Dml::Relation).to receive(:new).and_return(relation_instance)
    end

    it 'should return relation' do
      expect(instance.relation).to equal(relation_instance)
    end

    it 'should send params to relation' do
      expect(Dml::Relation).to receive(:new).with(name, [:id], instance.associations)
      instance.belongs_to_one(:profile)
      instance.relation
    end
  end

end
