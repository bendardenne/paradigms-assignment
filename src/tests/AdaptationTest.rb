#!/usr/bin/env ruby

require 'test/unit'
require_relative 'Context'
require_relative 'Phone/Phone.rb'
require_relative 'Phone/PhoneCall.rb'

class AdaptationTest < Test::Unit::TestCase
	def setup
		
		@phone = Phone.new
		@call = PhoneCall.new
	end

	def test_simpleAdaptation
		quietContext = Context.new("Quiet")
		quietContext.adaptClass(Phone, :advertise, lambda { |p| "vibrate" })
		
		# Default behaviour
		assert_equal @phone.advertise(@call), "ringtone"
	
		# Activate a context and check implementation	
		assert_nothing_raised {quietContext.activate}
		assert_equal @phone.advertise(@call), "vibrate"
	
		# Should go back to default	
		assert_nothing_raised {quietContext.deactivate}
		assert_equal @phone.advertise(@call), "ringtone"
	end

	def test_conflictingAdaptations
		quietContext = Context.new("Quiet")
		quietContext.adaptClass(Phone, :advertise, lambda { |p| "vibrate" })
		
		offHookContext = Context.new("Off-Hook")
		offHookContext.adaptClass(Phone, :advertise, lambda{|p| "off-hook"})
		
		assert_nothing_raised { offHookContext.activate }
		assert_raise { quietContext.activate }	

		assert_nothing_raised { offHookContext.deactivate }
	end

	def test_invalidAdaptation
		context = Context.new

		assert_raise(NameError) { 
			context.adaptClass(Phone, :areYouHigh?, lambda{ |x| return "high as kite" })
		}

		context.adaptClass(Phone, :advertise, lambda{ |x| return "Quiet" })
		assert_raise(ArgumentError) { 
			context.adaptClass(Phone, :advertise, lambda{ |x| return "Off-Hook" })
		}
		
	end
end
