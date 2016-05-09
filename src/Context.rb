#!/usr/bin/env ruby

require 'set'

require_relative 'ContextManager'
require_relative 'ContextAdaptation'

class Context

	attr_reader :manager, :activation_age

	@@default = nil
	@@age = 0

	def initialize(name = nil)
		@manager = ContextManager.instance
		@activation_count = 0
		@adaptations = Set.new
		@activation_age = 0
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

	def self.proceed(*args) 
		ContextManager.instance.proceed(args)
	end
	
	## Getter
	def name 
		@name
	end

	## Setter
	def name=(new_name)
		# TODO remove previous from manager 
		@name = new_name
		@manager.directory[@name] = self
	end

	def activate
		@activation_count += 1
		@activation_age = (@@age += 1);
		activate_adaptations
	end

	def deactivate
		if @activation_count > 0
			@activation_count -= 1
		end

		if not active? 
			deactivate_adaptations
		end
	end

	def discard
		if active? 
			raise ArgumentError, 'Attempting to discard an active context'	
		end
		@manager.discard(self)		
	end


	def activate_adaptations
		@adaptations.each{ |a| @manager.activate_adaptation(a) }
	end
	
	def deactivate_adaptations
		@adaptations.each{ |a| @manager.deactivate_adaptation(a) }
	end

	def adapt_class(adapted_class, selector, implementation)
		if adapts?(adapted_class, selector)
			raise ArgumentError, "#{self} already adapts #{adapted_class}:#{selector}"
		end
		
		adaptation = ContextAdaptation.new(self, adapted_class, selector, implementation)	
		@adaptations << adaptation							 

		if not Context.default.adapts?(adapted_class, selector)
			default_method = adapted_class.instance_method(selector)
			Context.default.adapt_class(adapted_class, selector, default_method)
		end

		if active? 
			manager.activate_adaptation(adaptation)
		end
	end
	
	def get_adaptation(a_class, selector)
		@adaptations.each{|a| 
			if a.adapted_class == a_class and a.selector == selector
				return a
			end
		}

		# TODO what if not in adaptations
	end

	##############
	# PREDICATES #	
	##############

	def adapts?(a_class, selector)
		
		@adaptations.each { |adapted| 
			if adapted.adapted_class == a_class and adapted.selector == selector
				return true
			end
		}
		
		return false
	end
	
	def active?
		@activation_count > 0
	end

	def to_s
		if @name == nil
			return "Anonymous context"
		end

		return "#{@name} context" 
	end
end
