require 'spec_helper'

describe Dml::Relations::Association::OneToOne do
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

  describe '#foreign_key' do
    subject { instance.foreign_key }

    context 'if target name and relation name are same' do
      context 'when specified in options' do
        let(:options) do
          { foreign_key: :info_id }
        end

        it { expect(subject).to equal(:info_id) }
      end

      context 'when not specified in options' do
        it { expect(subject).to equal(:profile_id) }
      end
    end

    context 'if target name is not the same with relation name' do
      let(:target_name)     { :activity_log }
      let(:target_relation) { :stats }

      context 'when specified in options' do
        let(:options) do
          { foreign_key: :activity_id }
        end

        it { expect(subject).to equal(:activity_id) }
      end

      context 'when not specified in options' do
        it { expect(subject).to equal(:activity_log_id) }
      end
    end
  end

  describe '#target_key' do
    subject { instance.target_key }

    context 'if target name and relation name are same' do
      context 'when specified in options' do
        let(:native_key) { :uuid }

        let(:options) do
          { target_key: native_key }
        end

        it { expect(subject).to equal(native_key) }
      end

      context 'when not specified in options' do
        it { expect(subject).to equal(:id) }
      end
    end

    context 'if target name is not the same with relation name' do
      context 'when specified in options' do
        let(:native_key) { :uuid }

        let(:options) do
          { target_key: native_key }
        end

        it { expect(subject).to equal(native_key) }
      end

      context 'when not specified in options' do
        it { expect(subject).to equal(:id) }
      end
    end
  end

end
