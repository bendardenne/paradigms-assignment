#!/usr/bin/env ruby

require 'test/unit'
require_relative '../Context'
require_relative '../Phone/Phone.rb'
require_relative '../Phone/DiscreetPhone.rb'
require_relative '../Phone/ScreeningPhone.rb'
require_relative '../Phone/PhoneCall.rb'
require_relative '../Phone/PhoneCall.rb'

class AdaptationTest < Test::Unit::TestCase
	def setup
		@phone = Phone.new
		@call = PhoneCall.new
		
		@screening = Context.new("screening") 
		method = ScreeningPhone.instance_method(:advertiseWithScreening)
		@screening.adaptClass(Phone, :advertise, method)
	end

	def teardown
		@screening.discard
	end

	def test_composition
		assert_nothing_raised { @screening.activate	}
		
		#assert_equal  @phone.receive(@call), "Ringtone with screening"
		@phone.advertise(@call)
	end

end
