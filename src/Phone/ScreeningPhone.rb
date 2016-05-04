require_relative 'Phone'

module ScreeningPhone

	def advertise_screening(call)
		"#{Context.proceed(call)} with screening"
	end

end
