#!/usr/bin/env ruby

require 'test/unit'
require_relative '../Context'

class InfrastructureTests < Test::Unit::TestCase
	def setup
		@myContext = Context.new
	end

	def test_fresh_is_inactive
		assert_equal @myContext.active? , false
	end

	def test_activate_deactivate 
		@myContext.activate
		assert @myContext.active?

		@myContext.deactivate
		assert_equal @myContext.active? , false
	end

	def test_redundant_activation 
		10.times { @myContext.activate }
		assert @myContext.active?

		9.times { @myContext.deactivate }
		assert @myContext.active?

		@myContext.deactivate 
		assert_equal @myContext.active? , false
	end

	def test_redundant_deactivation 
		5.times { @myContext.activate }
		assert @myContext.active?

		10.times { @myContext.deactivate }
		assert_equal @myContext.active? , false

		@myContext.activate 
		assert @myContext.active?
		
		@myContext.deactivate 
		assert_equal @myContext.active? , false
	end

	def test_named_contexts
		assert_nil @myContext.name
		assert_equal @myContext.to_s, 'Anonymous context'

		@myNamedContext = Context.new('Low Battery')
		assert_equal @myNamedContext.name, 'Low Battery' 
		assert_equal @myNamedContext.to_s, 'Low Battery context'

		@myNamedContext.name = 'High Battery'
		assert_equal @myNamedContext.name, 'High Battery'

		@otherNamedContext = Context.new("Afternoon")
		assert_not_same @myNamedContext, @otherNamedContext
	end

	def test_default
		assert_not_nil Context.default
		assert_equal Context.default.name, 'default'
		assert Context.default.active?
	
		Context.default = @myContext
		assert_same Context.default, @myContext 
		assert_nil Context.default.name 

		Context.default = nil
		assert_equal Context.default.name, 'default' 
	end
	
	def test_manager
		assert_not_nil @myContext.manager 
		
		assert_not_nil Context.default.manager
	
		assert_same Context.default.manager, @myContext.manager 
		
		Context.default = nil
		c = Context.new
		assert_not_nil c.manager	
	end

	def test_directory
		c = Context.new("Silent")
		assert c.manager.directory.has_key? "Silent"
		assert c.manager.directory.has_key? "default"

		c.discard
	
		assert_false c.manager.directory.has_key? "Silent"

		assert_raise(RuntimeError) { Context.default.discard }
		Context.default.deactivate
		assert_nothing_raised(RuntimeError) { Context.default.discard }
		assert_not_nil Context.default
	end
end
