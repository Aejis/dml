require 'spec_helper'

describe Dml::Repository do
  let(:model) do
    Class.new do
      attr_accessor :name, :email

      def initialize(name: nil, email: nil)
        @name  = name
        @email = email
      end

      def attributes
        { name: name, email: email }
      end
    end
  end

  let(:repo) do
    Class.new(described_class) do
      entity model
      relation :test_users
    end
  end

  describe 'Fetch' do

  end

  describe 'Insert' do

  end

  describe 'Update' do

  end

  describe 'Destroy' do

  end

end
