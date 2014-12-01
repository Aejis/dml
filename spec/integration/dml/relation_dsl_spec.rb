require 'spec_helper'

describe 'Relations DSL' do
  let(:relations) do
    Dml::Relation::DSL.new do
      relation :districts do
        key :code
      end

      relation :countries do
        key :id
      end

      relation :users do
        key :id

        belongs_to(:company)
        belongs_to_one(:profile)
        belongs_to_one(:activity_log) do
          relation :stats
        end
      end

      relation :profiles
      relation :stats

      relation :companies do
        key :id

        belongs_to(:region) do
          relation :districts
          foreign_key :region_code
          reference_key :code
        end
      end
    end
  end

  let(:result) { relations.result }

  describe 'relation list' do
    it 'should be sorted' do
      expect(result.names).to eql([:districts, :countries, :companies, :profiles, :stats, :users])
    end
  end

  describe 'relation' do
    subject { result.get(:profiles) }

    it 'should set the name' do
      expect(subject.name).to equal(:profiles)
    end

    it 'should set foreign key' do
      expect(subject.primary_key).to contain_exactly(:id)
    end
  end

  describe 'association list' do
    subject { result.get(:users) }

    it 'should set all associations' do
      expect(subject.dependencies).to contain_exactly(:companies, :profiles, :stats)
    end

    it 'should set dependencies' do
      expect(subject.associations.keys).to contain_exactly(:company, :profile, :activity_log)
    end
  end

  describe 'association' do
    subject { result[:companies].associations[:region] }

    it 'should set relation name' do
      expect(subject.target_relation).to equal(:districts)
    end

    it 'should set foreign key' do
      expect(subject.foreign_keys).to contain_exactly(:region_code)
    end

    it 'should set reference key' do
      expect(subject.target_keys).to contain_exactly(:code)
    end
  end

end
