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
		
		@quiet = Context.new("Quiet")
		quiet_method = DiscreetPhone.instance_method(:advertise_quietly)
		@quiet.adapt_class(Phone, :advertise, quiet_method)
		
		@wait = Context.new("Off-Hook")
		wait_method = lambda{|*args| "wait" }
		@wait.adapt_class(Phone, :advertise, wait_method)
	end

	def teardown
		@quiet.deactivate
		@quiet.discard
		@wait.deactivate
		@wait.discard
		Context.default.deactivate
		Context.default.discard
	end


	def test_simpleAdaptation
		# Default behaviour
		assert_equal @phone.receive(@call), "Ringtone"
	
		# Activate a context and check implementation	
		assert_nothing_raised {@quiet.activate}
		assert_equal @phone.receive(@call), "Vibrate"
	
		# Should go back to default	
		assert_nothing_raised {@quiet.deactivate}
		assert_equal @phone.receive(@call), "Ringtone"
	end
	
	# Multiple Contexts are now allowed
#	def test_conflictingAdaptations
#		assert_nothing_raised { @wait.activate }
#		assert_raise(ArgumentError) { @quiet.activate }	
#
#		assert_nothing_raised { @wait.deactivate }
#	end

	def test_invalid_adaptation
		context = Context.new

		assert_raise(NameError) { 
			context.adapt_class(Phone, :areYouHigh?, lambda{ |x| return "high as kite" })
		}

		context.adapt_class(Phone, :advertise, lambda{ |x| return "Quiet" })
		assert_raise(ArgumentError) { 
			context.adapt_class(Phone, :advertise, lambda{ |x| return "Off-Hook" })
		}
		
	end

end
