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
		method = ScreeningPhone.instance_method(:advertise_screening)
		@screening.adapt_class(Phone, :advertise, method)
		
		@quiet = Context.new("quiet") 
		method = DiscreetPhone.instance_method(:advertise_quietly)
		@quiet.adapt_class(Phone, :advertise, method)
	end

	def teardown
		@screening.deactivate
		@screening.discard
		
		@quiet.deactivate
		@quiet.discard
	end

	def test_composition
		assert_nothing_raised { @screening.activate	}
		
		assert_equal  @phone.receive(@call), "Ringtone with screening"
	end

	def test_chainedComposition
		assert_nothing_raised { @quiet.activate	}
		assert_nothing_raised { @screening.activate	}
		
		assert_equal  @phone.receive(@call), "Vibrate with screening"
		
		assert_nothing_raised { @quiet.deactivate	}
		assert_equal  @phone.receive(@call), "Ringtone with screening"
		
		assert_nothing_raised { @quiet.activate	}
		assert_equal  @phone.receive(@call), "Vibrate"
	end
end
