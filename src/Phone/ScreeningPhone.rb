require_relative 'Phone'

module ScreeningPhone

	def advertiseWithScreening(call)
		"#{Context.proceed(call)} with screening"
	end

end
