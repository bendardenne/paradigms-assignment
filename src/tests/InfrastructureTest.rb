#!/usr/bin/env ruby

require 'test/unit'
require_relative '../Context'

class InfrastructureTests < Test::Unit::TestCase
	def setup
		@my_context = Context.new
	end

	def test_fresh_is_inactive
		assert_equal @my_context.active? , false
	end

	def test_activate_deactivate 
		@my_context.activate
		assert @my_context.active?

		@my_context.deactivate
		assert_equal @my_context.active? , false
	end

	def test_redundant_activation 
		10.times { @my_context.activate }
		assert @my_context.active?

		9.times { @my_context.deactivate }
		assert @my_context.active?

		@my_context.deactivate 
		assert_equal @my_context.active? , false
	end

	def test_redundant_deactivation 
		5.times { @my_context.activate }
		assert @my_context.active?

		10.times { @my_context.deactivate }
		assert_equal @my_context.active? , false

		@my_context.activate 
		assert @my_context.active?
		
		@my_context.deactivate 
		assert_equal @my_context.active? , false
	end
	
	def test_no_stacked_activation
		10.times { @my_context.activate(multiple_activation = false) }
		assert @my_context.active?
		
		@my_context = Context.new("MyContext", multiple_activation: false)
		10.times { @my_context.activate }
		assert @my_context.active?

		@my_context.deactivate
		assert_false @my_context.active?
	end

	def test_named_contexts
		assert_nil @my_context.name
		assert_equal @my_context.to_s, 'Anonymous context'

		@named_context = Context.new('Low Battery')
		assert_equal @named_context.name, 'Low Battery' 
		assert_equal @named_context.to_s, 'Low Battery context'

		@named_context.name = 'High Battery'
		assert_equal @named_context.name, 'High Battery'

		@other_context = Context.new("Afternoon")
		assert_not_same @named_context, @other_context
	end

	def test_default
		assert_not_nil Context.default
		assert_equal Context.default.name, 'default'
		assert Context.default.active?
	
		Context.default = @my_context
		assert_same Context.default, @my_context 
		assert_nil Context.default.name 

		Context.default = nil
		assert_equal Context.default.name, 'default' 
	end
	
	def test_manager
		assert_not_nil @my_context.manager 
		assert_not_nil Context.default.manager
	
		assert_same Context.default.manager, @my_context.manager 
		
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

		assert_raise(ArgumentError) { Context.default.discard }
		Context.default.deactivate
		assert_nothing_raised(RuntimeError) { Context.default.discard }
		assert_not_nil Context.default
	end
end
