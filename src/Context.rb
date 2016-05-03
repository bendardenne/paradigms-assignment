#!/usr/bin/env ruby

require 'set'

require_relative 'ContextManager'
require_relative 'ContextAdaptation'

class Context

	@@default, @manager = nil

	def initialize(name = nil)
		@activationCount = 0
		@adaptations = Set.new
		if name != nil
			self.name = name
		end
	end


	## Getter
	def self.default 
		if @@default == nil
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
		activateAdaptations
	end

	def deactivate
		if @activationCount > 0
			@activationCount -= 1
		end

		if not active? 
			deactivateAdaptations
		end
	end

	def active?
		@activationCount > 0
	end

	def discard
		if active? 
			raise ArgumentError, 'Attempting to discard an active context'	
		end
		@manager.discard(self)		
	end


	def activateAdaptations
		@adaptations.each{ |a| puts a;  @manager.activateAdaptation(a) }
	end
	
	def deactivateAdaptations
		@adaptations.each{ |a| @manager.deactivateAdaptation(a) }
	end

	def adaptClass(adaptedClass, selector, implementation)
		if adapts?(adaptedClass, selector)
			raise ArgumentError, "#{self}already adapts #{adaptedClass}:#{selector}"
		end
		
		adaptation = ContextAdaptation.new(self, adaptedClass, selector, implementation)	
		@adaptations << adaptation							 

		if not Context.default.adapts?(adaptedClass, selector)
			defaultMethod = adaptedClass.instance_method(selector)
			Context.default.adaptClass(adaptedClass, selector, defaultMethod)
		end

		if active? 
			manager.activateAdaptation(adaptation)
		end
	end

	def adapts?(aClass, selector)
		
		@adaptations.each { |adapted| 
			if adapted.adaptedClass == aClass and adapted.selector == selector
				return true
			end
		}
		
		return false
	end

	def getAdaptation(aClass, selector)
		@adaptations.each{|a| 
			if a.adaptedClass == aClass and a.selector == selector
				return a
			end
		}

		# TODO what if not in adaptations
	end

	def to_s
		if @name == nil
			return "Anonymous context"
		end

		return "#{@name} context" 
	end
end
