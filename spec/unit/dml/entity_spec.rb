require 'spec_helper'

describe Dml::Entity do
  let(:entity) do
    Class.new(described_class) do
      attribute :number, Integer
      attribute :string, String
      attribute :bool, Virtus::Attribute::Boolean
    end
  end

  context '#initialize and #attributes' do
    let(:params) { { number: 5, string: 'yup', bool: true } }

    it 'should initialize' do
      expect { entity.new(params) }.to_not raise_error
    end

    it 'should has attributes' do
      rec = entity.new(params)

      expect(rec.attributes).to eq(params)
    end
  end

  context '.attribute' do
    let(:record) { entity.new }

    it 'should create getter' do
      expect(record).to be_respond_to(:number)
    end

    it 'should create setter' do
      expect(record).to be_respond_to(:number=)
    end

    it 'should provide basic coercions' do
      record.number = '5'
      record.string = 5
      expect(record.number).to eq(5)
      expect(record.string).to eq('5')
    end
  end
end
