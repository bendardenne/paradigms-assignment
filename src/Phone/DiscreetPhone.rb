require_relative "Phone"

class DiscreetPhone < Phone

	def advertiseQuietly
		"Vibrate"
	end
	
	def advertiseDiscreteBeep
		"Discrete beep"
	end	

end
