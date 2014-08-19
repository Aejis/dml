$: << File.expand_path(File.dirname(__FILE__))

require 'bundler'

Bundler.setup

require 'sequelize/thor/db'
require 'db'
