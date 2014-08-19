require 'sequelize'

Sequelize.configure do
  root        File.expand_path(File.dirname(__FILE__))
  config_file 'etc/database.yml'
end

Sequelize.setup(ENV['DB_ENV'] || 'test')

