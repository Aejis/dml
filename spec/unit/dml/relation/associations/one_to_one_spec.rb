require 'spec_helper'

describe Dml::Relation::Associations::OneToOne do
  let(:instance) do
    described_class.new(source_name, target_name, options)
  end

  let(:source_name)     { :users }
  let(:target_name)     { :profile }
  let(:target_relation) { :profiles }
  let(:options)         { Hash[] }

  describe '#type' do
    subject { instance.type }

    it { expect(subject).to equal(:one_to_one) }
  end

  describe '#source_relation' do
    subject { instance.source_relation }

    it { expect(subject).to equal(source_name) }
  end

  describe '#target_relation' do
    subject { instance.target_relation }

    context 'when specified in options' do
      let(:target_name)     { :activity_log }
      let(:target_relation) { :stats }

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
          let(:fk) { :info_id }

          it { expect(subject).to contain_exactly(fk) }
        end

        context 'multiple keys' do
          let(:fk) { [:info_id, :company_id] }

          it { expect(subject).to match_array(fk) }
        end
      end

      context 'when not specified in options' do
        it { expect(subject).to contain_exactly(:profile_id) }
      end
    end

    context 'if target name is not the same with relation name' do
      let(:target_name)     { :activity_log }
      let(:target_relation) { :stats }

      context 'when specified in options' do
        context 'single key' do
          let(:options) do
            { foreign_keys: :activity_id }
          end

          it { expect(subject).to contain_exactly(:activity_id) }
        end

        context 'multiple keys' do
          let(:options) do
            { foreign_keys: [:activity_id, :activity_type] }
          end

          it { expect(subject).to contain_exactly(:activity_id, :activity_type) }
        end
      end

      context 'when not specified in options' do
        it { expect(subject).to contain_exactly(:activity_log_id) }
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
      it { expect(subject).to match(:profile_id => :id) }
    end

    context 'when many keys' do
      let(:options) do
        {
          foreign_keys: [:profile_id, :profile_type],
          target_keys:  [:id, :type]
        }
      end

      it { expect(subject).to match({ :profile_id => :id, :profile_type => :type }) }
    end
  end

end
