#!/usr/bin/env ruby

require 'test/unit'
require_relative '../Context'
require_relative '../Phone/Phone.rb'
require_relative '../Phone/DiscreetPhone.rb'
require_relative '../Phone/MulticallPhone.rb'
require_relative '../Phone/PhoneCall.rb'

class AdaptationTest < Test::Unit::TestCase
	def setup
		
		@phone = Phone.new
		@call = PhoneCall.new
		
		@quietContext = Context.new("Quiet")
		quietMethod = DiscreetPhone.instance_method(:advertiseQuietly)
		@quietContext.adaptClass(Phone, :advertise, quietMethod)
		
		@waitSignalContext = Context.new("Off-Hook")
		waitMethod = MulticallPhone.instance_method(:advertiseWaitCall)
		@waitSignalContext.adaptClass(Phone, :advertise, waitMethod)
	end

	def teardown
		@quietContext.deactivate
		@quietContext.discard
		@waitSignalContext.deactivate
		@waitSignalContext.discard
	end


	def test_simpleAdaptation
		# Default behaviour
		assert_equal @phone.receive(@call), "Ringtone"
	
		# Activate a context and check implementation	
		assert_nothing_raised {@quietContext.activate}
		assert_equal @phone.receive(@call), "Vibrate"
	
		# Should go back to default	
		assert_nothing_raised {@quietContext.deactivate}
		assert_equal @phone.receive(@call), "Ringtone"
	end

	def test_conflictingAdaptations
		assert_nothing_raised { @waitSignalContext.activate }
		assert_raise(ArgumentError) { @quietContext.activate }	

		assert_nothing_raised { @waitSignalContext.deactivate }
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
