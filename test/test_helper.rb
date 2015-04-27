require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/fire_mock'

Minitest::Reporters.use!

ENV['SLACK_TOKEN'] = 'faketoken'

require './app'
