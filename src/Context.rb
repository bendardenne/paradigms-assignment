#!/usr/bin/env ruby

require_relative 'ContextManager'

class Context

	attr_accessor :name
	@@default, @manager = nil
	
	def initialize(name = nil)
		@activationCount = 0
		@name = name
	end


	## Getter
	def self.default 
		if @@default == nil
			@@default = Context.new('default')
			@@default.activate
			@@default.manager = ContextManager.new
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
			@manager = Context.default.manager 
		end	

		return @manager
	end

	## Setter
	def manager=(newManager)
		@manager = newManager
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

	def discard
		
	end

	def to_s
		if @name == nil
			return "Anonymous context"
		end

		return "#{@name} context" 
	end
end
