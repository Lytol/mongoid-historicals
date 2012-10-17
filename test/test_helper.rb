require 'mongoid'
require 'minitest/autorun'

require_relative '../lib/mongoid/historicals'
require_relative 'example/player'

Mongoid.load!(File.join(File.dirname(__FILE__), "example/mongoid.yml"), :test)
