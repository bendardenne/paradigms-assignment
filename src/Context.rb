#!/usr/bin/env ruby

require_relative 'ContextManager'

class Context

	@@default, @manager = nil
	
	def initialize(name = nil)
		@activationCount = 0
		if name != nil
			self.name = name
		end
	end


	## Getter
	def self.default 
		if @@default == nil
			#@@default = Context.new('default')
			@@default = Context.new
			@@default.name = 'default'
			@@default.activate
		end

		return @@default
	end	

	## Setter 
	def self.default=(newDefault)
		@@default = newDefault
	end
	
	## Getter	
	def manager 
		if @manager == nil 
			if self == Context.default 
				@manager = ContextManager.new
			else
				@manager = Context.default.manager 
			end
		end	

		return @manager
	end

	## Setter
	def manager=(newManager)
		@manager = newManager
	end

	## Getter
	def name 
		@name
	end

	## Setter
	def name=(newName)
		# TODO remove previous from manager 
		@name = newName
		self.manager.directory[@name] = self
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
		@activationCount > 0
	end

	def discard
		if active? 
			raise 'Attempting to discard an active context'	
		end
		@manager.discard(self)		
	end

	def to_s
		if @name == nil
			return "Anonymous context"
		end

		return "#{@name} context" 
	end
end
