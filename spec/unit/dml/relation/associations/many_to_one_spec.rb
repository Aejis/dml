require 'spec_helper'

describe Dml::Relation::Associations::ManyToOne do
  let(:instance) do
    described_class.new(source_name, target_name, options)
  end

  let(:source_name)     { :users }
  let(:target_name)     { :company }
  let(:target_relation) { :companies }
  let(:options)         { Hash[] }

  describe '#type' do
    subject { instance.type }

    it { expect(subject).to equal(:many_to_one) }
  end

  describe '#source_relation' do
    subject { instance.source_relation }

    it { expect(subject).to equal(source_name) }
  end

  describe '#target_relation' do
    subject { instance.target_relation }

    context 'when specified in options' do
      let(:target_name)     { :motherland }
      let(:target_relation) { :countries }

      let(:options) do
        { target_relation: target_relation }
      end

      it { expect(subject).to equal(target_relation) }
    end

    context 'when not specified in options' do
      it { expect(subject).to equal(target_relation) }
    end
  end

  describe '#target_name' do
    subject { instance.target_name }

    it { expect(subject).to equal(target_name) }
  end

  describe '#foreign_keys' do
    subject { instance.foreign_keys }

    context 'if target name and relation name are same' do
      context 'when specified in options' do
        let(:options) do
          { foreign_keys: fk }
        end

        context 'single key' do
          let(:fk) { :motherland_id }

          it { expect(subject).to contain_exactly(fk) }
        end

        context 'multiple key' do
          let(:fk) { [:motherland_id, :zip] }

          it { expect(subject).to match_array(fk) }
        end
      end

      context 'when not specified in options' do
        it { expect(subject).to contain_exactly(:company_id) }
      end
    end

    context 'if target name is not the same with relation name' do
      let(:target_name)     { :division }
      let(:target_relation) { :regions }

      context 'when specified in options' do
        let(:options) do
          { foreign_keys: fk }
        end

        context 'single key' do
          let(:fk) { :region_code }

          it { expect(subject).to contain_exactly(fk) }
        end

        context 'multiple keys' do
          let(:fk) { [:region_code, :zip] }

          it { expect(subject).to match_array(fk) }
        end
      end

      context 'when not specified in options' do
        it { expect(subject).to contain_exactly(:division_id) }
      end
    end
  end

  describe '#target_keys' do
    subject { instance.target_keys }

    context 'when specified in options' do
      let(:options) do
        { target_keys: native_key }
      end

      context 'single key' do
        let(:native_key) { :uuid }

        it { expect(subject).to match_array(native_key) }
      end

      context 'multiple keys' do
        let(:native_key) { [:uuid, :type] }

        it { expect(subject).to match_array(native_key) }
      end
    end

    context 'when not specified in options' do
      it { expect(subject).to contain_exactly(:id) }
    end
  end

  describe '#reference_keys' do
    subject { instance.reference_keys }

    context 'when one key' do
      it { expect(subject).to match(:company_id => :id) }
    end

    context 'when many keys' do
      let(:options) do
        {
          foreign_keys: [:company_id, :company_country],
          target_keys: [:id, :country_id]
        }
      end

      it { expect(subject).to match({ :company_id => :id, :company_country => :country_id }) }
    end
  end

end
