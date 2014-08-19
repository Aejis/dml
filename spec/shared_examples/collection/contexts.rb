RSpec.shared_context 'Dml::Collection' do
  let(:data) do
    [
      { name: 'John', email: 'john@example.com', age: 21 },
      { name: 'July', email: 'july@example.com', age: 22 },
      { name: 'Josh', email: 'josh@example.com', age: 23 }
    ]
  end

  let(:entity) do
    Class.new do
      attr_accessor :name, :email, :age

      def initialize(id: nil, name: nil, email: nil, age: nil)
        @id    = id
        @name  = name
        @email = email
        @age   = age
      end

      def attributes
        { id: nil, name: name, email: email, age: nil }
      end

      def eql?(other)
        name == other.name && email == other.email && age == other.age
      end
      alias_method :===, :eql?
    end
  end
end

RSpec.shared_context 'Dml::Collection from database' do
  include_context 'Dml::Collection'

  before(:each) do
    DB.create_table(:test_users) do
      primary_key :id

      column :name,  :text
      column :email, :text
      column :age,   :integer
    end

    DB[:test_users].multi_insert(data)
  end

  after(:each) do
    DB.drop_table(:test_users)
  end
end
