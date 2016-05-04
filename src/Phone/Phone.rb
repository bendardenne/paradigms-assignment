require_relative '../MethodAdaptation'
class Phone
	
	prepend MethodAdaptation
	
	def advertise(phoneCall)
		"Ringtone"
	end

	def receive(phoneCall)
		advertise(phoneCall)
	end	

end
