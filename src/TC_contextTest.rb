require 'test/unit'
require 'Context.rb'
class TC_ContextTest < Test::Unit::TestCase
	def setup
		@myContext = Context.new()
	end

	def test_fresh_is_inactive
		assert_equal @myContext.active? , false
	end
end