#!/usr/bin/env ruby

class Context

	def initialize
		@activationCount = 0
	end

	def initialize(name)
			
	end

	def activate
		@activationCount += 1
	end

	def deactivate
		if @activationCount > 0
			@activationCount -= 1
		end
	end

	def active?
		return @activationCount > 0
	end

end
