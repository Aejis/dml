require 'spec_helper'

describe Dml::Repository::Resource do

  class Post < Dml::Entity
    include Virtus.model

    attribute :id,      Integer
    attribute :name,    String
    attribute :likes,   Integer
    attribute :user_id, Integer
  end

  class User < Dml::Entity
    include Virtus.model

    attribute :id,    Integer
    attribute :login, String
  end

  before(:each) do
    DB.create_table(:posts) do
      primary_key :id

      column :name,    String
      column :likes,   Integer
      column :user_id, Integer
    end

    DB.create_table(:users) do
      primary_key :id

      column :login, String
    end
  end

  after(:each) do |attrs|
    DB.drop_table(:posts)
    DB.drop_table(:users)
  end

  let(:posts_attrs) do
    [
      { name: 'New post',        likes: 1000, user_id: user.id },
      { name: 'Other old post',  likes: 999,  user_id: user.id },
      { name: 'Post about ruby', likes: 1500, user_id: user.id },
      { name: 'Post about faye', likes: 500,  user_id: user.id }
    ]
  end

  let!(:posts) do
    posts_attrs.map do |attrs|
      repo.insert(Post.new(attrs)).first
    end
  end

  let!(:user) { users_repo.insert(User.new(login: 'login')).first }

  let(:repo) do
    Class.new(described_class) do
      entity Post
      relation :posts

      on_retrieve do |attrs|
        attrs.merge!(name: 'changed')

        attrs
      end

      query :popular do
        where { likes > 1000 }
      end

      finder(:by_name) do |name|
        where(name: name)
      end
    end
  end

  let(:users_repo) do
    Class.new(described_class) do
      entity User
      relation :users
    end
  end

  describe '#on_retrieve' do
    context 'with #fetch' do
      it 'should modify attributes' do
        posts.each do |post|
          fetched = repo.fetch(post.id)
          expect(fetched.name).to eql('changed')
        end
      end
    end

    context 'with #query' do
      let(:found_posts) { repo.popular }

      it 'should modify attributes' do
        found_posts.each do |post|
          expect(post.name).to eql('changed')
        end
      end
    end

    context 'with #finder' do
      let(:found_post) { repo.by_name(posts_attrs.first[:name]) }

      it 'should modify attributes' do
        expect(found_post.name).to eql('changed')
      end
    end

    context 'with #belong_to' do
      let(:found_posts) { repo.belong_to(:user, user) }

      it 'should modify attributes' do
        found_posts.each do |post|
          expect(post.name).to eql('changed')
        end
      end
    end
  end
end
