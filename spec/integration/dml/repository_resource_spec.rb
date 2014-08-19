require 'spec_helper'

describe Dml::Repository::Resource do
  before(:each) do
    DB.create_table(:test_users) do
      primary_key :id

      column :name,  :text
      column :email, :text
      column :age,   :integer
    end

    DB.create_table(:test_notes) do
      primary_key [:id, :test_user_id], name: :test_notes_key
      column :id,      :serial
      column :test_user_id, :serial
      column :text,    :text
    end
    @note_id = 0
  end

  after(:each) do
    DB.drop_table(:test_users)
    DB.drop_table(:test_notes)
  end

  let(:test_user_entity) do
    Class.new do
      include Virtus.model

      attribute :id, Integer
      attribute :name, String
      attribute :email, String
      attribute :age, Integer
    end
  end

  let(:test_note_entity) do
    Class.new do
      include Virtus.model

      attribute :id, Integer
      attribute :test_user_id, Integer
      attribute :text, String
    end
  end

  let(:test_users_repo) do
    model = test_user_entity
    Class.new(described_class) do
      entity model
      relation :test_users
    end
  end

  let(:test_notes_repo) do
    model = test_note_entity
    Class.new(described_class) do
      entity model
      relation :test_notes
    end
  end

  def note
    @note_id += 1
    test_note_entity.new(id: @note_id, test_user_id: 5, text: 'old text')
  end
  let!(:test_notes) { 10.times.map { note } }

  let(:user) { test_user_entity.new(name: 'somename', email: 'mail', age: 32) }
  let(:test_users) { 10.times.map { user } }

  describe 'Insert' do
    context 'insert one user' do
      it 'should insert' do
        test_users_repo.insert(user)
        expect(DB[:test_users].all.size).to eql(1)
      end

      it 'should set primary key' do
        expect(test_users_repo.insert(user).first.id).to be_kind_of(Integer)
      end
    end

    context 'insert many records' do
      it 'should insert many records' do
        test_users_repo.insert(test_users)
        expect(DB[:test_users].all.size).to eql(10)
      end

      it 'should set primary keys' do
        inserted = test_users_repo.insert(test_users)

        inserted.each do |entity|
          expect(entity.id).to be_kind_of(Integer)
        end
      end
    end

    context 'aliases' do
      it '.create' do
        expect(test_users_repo).to be_respond_to(:create)
      end
    end

    context 'composite primary key' do
      it 'should insert' do
        test_notes_repo.insert(test_notes)
        expect(DB[:test_notes].all.size).to eql(10)
      end

      it 'should set primary keys' do
        inserted = test_notes_repo.insert(test_notes)

        inserted.each do |item|
          expect(item.id).to be_kind_of(Integer)
          expect(item.test_user_id).to be_kind_of(Integer)
        end
      end
    end
  end

  describe 'Fetch' do
    context 'one user' do
      it 'should fetch' do
        test_users_repo.insert(user)

        expect(test_users_repo.fetch(1).name).to eql(user.name)
      end

      it 'if worng id should return nil' do
        expect(test_users_repo.fetch(5)).to be_nil
      end
    end

    context 'method aliases' do
      it '.[] alias' do
        expect(test_users_repo).to be_respond_to(:[])
      end
      it '.find alias' do
        expect(test_users_repo).to be_respond_to(:find)
      end
    end

    context 'composite primary key' do
      it 'should fetch' do
        test_notes_repo.insert(note)
        expect(test_notes_repo.fetch([@note_id, 5])).to_not be_nil
      end
    end
  end

  describe 'Update' do
    context 'one record' do
      it 'should update' do
        test_users_repo.insert(user)
        record = test_users_repo[1]
        record.name = 'new_name'

        expect(test_users_repo.update(record)).to eql(1)
        expect(test_users_repo[1].name).to eql('new_name')
      end

      it 'should not touch other records' do
        test_users_repo.insert(test_users)
        record = test_users_repo[1]
        record.name = 'new_name'

        expect(test_users_repo.update(record)).to eql(1)
        expect(test_users_repo[2].name).to_not eql('new_name')
      end
    end

    context 'many records' do
      before(:each) do
        test_users_repo.insert(test_users)

        records.map! do |user|
          user.name = 'new_name'
          user
        end
      end

      let(:records) { [1, 2, 3].map { |x| test_users_repo[x] } }

      it 'should update' do
        expect(test_users_repo.update(records)).to eql(3)

        [1, 2, 3].each { |x| expect(test_users_repo[x].name).to eql('new_name') }
      end

      it 'should not touch other records' do
        expect(test_users_repo.update(records)).to eql(3)
        expect(test_users_repo[4].name).to_not eql('new_name')
      end
    end

    context 'composite key' do
      it 'should update' do
        test_notes_repo.insert(note)
        test_note = test_notes_repo.fetch([@note_id, 5])
        test_note.text = 'new awesome text'
        test_notes_repo.update(test_note)

        expect(test_notes_repo[[@note_id, 5]].text).to eql('new awesome text')
      end

      it 'should not touch other records' do
        test_notes_repo.insert(test_notes)
        test_note = test_notes_repo.fetch([@note_id, 5])
        test_note.text = 'new awesome text'
        test_notes_repo.update(test_note)

        expect(test_notes_repo[[@note_id - 1, 5]].text).to eql('old text')
      end
    end
  end

  describe 'Destroy' do
    context 'deleting one record' do
      it 'should delete' do
        test_users_repo.insert(test_users)
        record = test_users_repo[1]

        expect(test_users_repo.destroy(record)).to eql(1)
        expect(test_users_repo[1]).to be_nil
      end
    end

    context 'deleting many records' do
      it 'should delete' do
        test_users_repo.insert(test_users)
        records = [1, 2, 3].map { |i|test_users_repo[i] }

        expect(test_users_repo.destroy(records)).to eql(3)
        expect(DB[:test_users].all.size).to eql(7)
      end
    end

    context 'aliases' do
      it '.delete' do
        expect(test_users_repo).to be_respond_to(:delete)
      end
    end

    context 'composite key' do
      it 'should delete' do
        test_notes_repo.insert(test_notes)
        record = test_notes_repo[[@note_id, 5]]

        expect(test_notes_repo.destroy(record)).to eql(1)
        expect(test_notes_repo[[@note_id, 5]]).to be_nil
        expect(test_notes_repo[[@note_id - 1, 5]]).to_not be_nil
      end
    end
  end

end
