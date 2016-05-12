class Phone

	def initialize(name)
		@owner = name 
	end

	def advertise(phoneCall)
		"Ringtone" # for #{@owner}"
	end

	def receive(phoneCall)
		advertise(phoneCall)
	end	

	def call(someone)
		"Calling #{someone}"
	end

end
