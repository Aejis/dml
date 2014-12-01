require 'spec_helper'

describe Dml::Repository::PersistProcessor do
  let(:instance) { described_class.new(relation_name, primary_keys, callbacks) }

  let(:relation_name) { :users }
  let(:primary_keys)  { [:id] }
  let(:callbacks)     { [] }

  let(:entities) do
    [
      instance_double('Dml::Entity', attributes: { id: 1, company_id: 1, age: 18, name: 'John' }),
      instance_double('Dml::Entity', attributes: { id: 2, company_id: 1, age: 21, name: 'Mary' })
    ]
  end

  describe '#process_insert' do
    subject { instance.process_insert(entities) }

    context 'with callbacks' do
      let(:callbacks) do
        [
          ->(attrs) { attrs[:age] = attrs[:age].to_s; attrs },
          ->(attrs) { attrs[:name] = attrs[:name].downcase; attrs }
        ]
      end

      it 'processes all entities' do
        expect(subject.first).to include(age: '18', name: 'john')
        expect(subject.last).to  include(age: '21', name: 'mary')
      end
    end

    context 'without callbacks' do
      let(:callbacks) { [] }

      it 'returns the same hash' do
        expect(subject.first).to include(entities.first.attributes)
      end
    end
  end

  describe '#process_update' do
    subject { instance.process_update(entities) }

    context 'with callbacks' do
      let(:callbacks) do
        [
          ->(attrs) { attrs[:age]  = attrs[:age].to_s; attrs },
          ->(attrs) { attrs[:name] = attrs[:name].downcase; attrs }
        ]
      end

      it 'processes all entities' do
        expect(subject.data.first).to include(age: '18', name: 'john')
        expect(subject.data.last).to  include(age: '21', name: 'mary')
      end
    end

    context 'without callbacks' do
      let(:callbacks) { [] }

      it 'returns the same hash' do
        expect(subject.data.first).to include(entities.first.attributes)
      end
    end

    context 'with one pk' do
      let(:primary_keys) { [:id] }

      it 'extracts pkeys' do
        expect(subject.pkeys).to eql([{ id: 1}, { id: 2 }])
      end

      it 'does not touch anything' do
        expect(subject.data.first).to include(entities.first.attributes)
        expect(subject.data.last).to  include(entities.last.attributes)
      end
    end

    context 'with many pks' do
      let(:primary_keys) { [:id, :company_id] }

      it 'does not touch anything' do
        expect(subject.data.first).to include(entities.first.attributes)
        expect(subject.data.last).to  include(entities.last.attributes)
      end
    end

    context 'when pk does not present in attributes' do
      let(:primary_keys) { [:code] }

      it 'returns the same hash' do
        expect(subject.data.first).to include(entities.first.attributes)
      end
    end
  end

end
