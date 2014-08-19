require 'spec_helper'

describe Dml::Repository::Resource do
  ##
  # Class: for testing resource
  #
  class Movie < Dml::Entity
    include Virtus.model

    attribute :id,       Integer
    attribute :name,     String
    attribute :category, String
    attribute :imdb_id,  String
    attribute :year,     Integer
    attribute :display,  Boolean
  end

  before(:each) do
    DB.create_table(:movies) do
      primary_key :id

      column :name,     String
      column :category, String
      column :imdb_id,  String
      column :year,     Integer
      column :display,  :boolean
    end

    movies.each do |attrs|
      repo.insert(Movie.new(attrs))
    end
  end

  after(:each) do
    DB.drop_table(:movies)
  end

  let(:movies) do
    [
      { name: 'Repo Men',        category: 'sci-fi', imdb_id: '1053424', year: 2010, display: true },
      { name: 'Hot Fuzz',        category: 'comedy', imdb_id: '0425112', year: 2007, display: true },
      { name: 'Your Highness',   category: 'comedy', imdb_id: '1240982', year: 2011, display: true },
      { name: 'Borat',           category: 'comedy', imdb_id: '0443453', year: 2006, display: true },
      { name: 'The Matrix',      category: 'sci-fi', imdb_id: '0133093', year: 1999, display: true },
      { name: 'Children of Men', category: 'sci-fi', imdb_id: '0206634', year: 2006, display: false }
    ]
  end

  let(:repo) do
    Class.new(described_class) do
      entity Movie
      relation :movies

      default_query do
        where(display: true)
      end

      finder(:imdb) do |id|
        where(imdb_id: id)
      end

      query :category do |cat|
        where(category: cat)
      end

      query :old do
        where { year < 2009 }
      end

      query :old_comedy do
        with(:old)
        where(category: 'comedy')
      end

      query :sci_fi, default_query: false do
        where(category: 'sci-fi')
      end
    end
  end

  describe '#finder' do
    it 'returns result wrapped in entity' do
      result = repo.imdb('0133093')

      expect(result).to      be_a(Dml::Entity)
      expect(result.name).to eql('The Matrix')
    end

    it 'returns only one result' do
      result = repo.imdb(['0443453', '0206634'])

      expect(result).to be_a(Dml::Entity)
    end

    it 'returns nil when no record' do
      result = repo.imdb('666')

      expect(result).to be(nil)
    end
  end

  describe '#query' do
    it 'returns collection of results' do
      result = repo.category('comedy')

      expect(result).to be_kind_of(Dml::Collection)
    end

    it 'filter the results' do
      result = repo.category('comedy').map(&:name)

      expect(result).to contain_exactly('Hot Fuzz', 'Your Highness', 'Borat')
    end

    it 'reuse another queries' do
      result = repo.old_comedy.map(&:name)

      expect(result).to contain_exactly('Hot Fuzz', 'Borat')
    end

    it 'ignore default query' do
      result = repo.sci_fi.map(&:name)

      expect(result).to contain_exactly('Repo Men', 'The Matrix', 'Children of Men')
    end

    it 'returns empty result when no records' do
      result = repo.category('drama').map(&:name)

      expect(result).to be_empty
    end
  end

end
