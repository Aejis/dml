RSpec.shared_context 'dsl association' do
  before(:each) do
    allow(klass).to receive(:new)
  end

  after(:each) do
    instance.association
  end

  describe '#relation' do
    before(:each) do
      instance.relation(:profiles)
    end

    it { expect(klass).to receive(:new).with(:users, :info, { :target_relation => :profiles }) }
  end

  describe '#foreign_key' do
    context 'when single' do
      before(:each) do
        instance.foreign_key(:uid)
      end

      it { expect(klass).to receive(:new).with(:users, :info, { :foreign_keys => [:uid] }) }
    end

    context 'when composite' do
      before(:each) do
        instance.foreign_key(:id, :user_id)
      end

      it { expect(klass).to receive(:new).with(:users, :info, { :foreign_keys => [:id, :user_id] }) }
    end
  end

  describe '#reference_key' do
    context 'when single' do
      before(:each) do
        instance.reference_key(:uid)
      end

      it { expect(klass).to receive(:new).with(:users, :info, { :target_keys => [:uid] }) }
    end

    context 'when composite' do
      before(:each) do
        instance.reference_key(:id, :user_id)
      end

      it { expect(klass).to receive(:new).with(:users, :info, { :target_keys => [:id, :user_id] }) }
    end
  end
end
