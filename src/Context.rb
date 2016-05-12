#!/usr/bin/env ruby

require 'set'


# Adding the required modules
require_relative 'ContextManager'
require_relative 'ContextAdaptation'

class Context

	# multiple_activation: If it is allowed to activate this context multible times or not  
	attr_reader :manager, :multiple_activation 

	# Class variable to store the default context
	@@default = nil
	# Class variable to store the current age (used in the policy)
	@@age = 0

	
	def initialize(name = nil, multiple_activation: true)
		@manager = ContextManager.instance
		@activation_count = 0
		@adaptations = Set.new
		@activation_age = 0
		@multiple_activation = multiple_activation
		if name != nil
			self.name = name
		end
	end


	# Get the default context, if it is not created yet, a default context will be created and activated
	def self.default 
		if @@default == nil
			@@default = Context.new
			@@default.name = 'default'
			@@default.activate
		end

		return @@default
	end	

	# Set the default manually
	def self.default=(newDefault)
		@@default = newDefault
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

	# Calculating activation age of the context
	def activation_age
		@@age - @activation_age
	end

	# Activate the context
	def activate(multiple_activation = @multiple_activation)
		# If this context allows multiple activation, we increase activation_count
		if multiple_activation
			@activation_count += 1
		# If does not, and if it is not active yet, we set the activation_count to 1
		elsif not active?
			@activation_count = 1
		end

		# Set the activation age
		@activation_age = (@@age += 1);
		# Activate the adaptations of this context
		activate_adaptations
	end

	# Deactivating the context
	def deactivate
		# Decrease the number of activation count
		if @activation_count > 0
			@activation_count -= 1
		end

		# After decreasing the count, if it is 0, we should deactivate the context adaptations
		if not active? 
			deactivate_adaptations
		end
	end

	# Discarding the context
	def discard
		# It is not allowed to discard active contexts
		if active? 
			raise ArgumentError, 'Attempting to discard an active context'	
		end

		# Send the discarding request to the manager to delete the context
		@manager.discard(self)		
	end

	# Activate all adaptations in the current context
	def activate_adaptations
		@adaptations.each{ |a| @manager.activate_adaptation(a) }
	end
	
	# Deactivate all adaptations in the current context
	def deactivate_adaptations
		@adaptations.each{ |a| @manager.deactivate_adaptation(a) }
	end

	# Implement an adaptation for the "selector" method in the "adapted_class" with the new "implementation"
	def adapt_class(adapted_class, selector, implementation)
		# Make sure this context didn't adapt the same method before
		if adapts?(adapted_class, selector)
			raise ArgumentError, "#{self} already adapts #{adapted_class}:#{selector}"
		end
		
		# Create the new adaptation and add it to the adaptations set
		adaptation = ContextAdaptation.new(self, adapted_class, selector, implementation)	
		@adaptations << adaptation							 

		# if the default has no implementation for the method, 
		# we store the current implementation in the default
		if not Context.default.adapts?(adapted_class, selector)
			default_method = adapted_class.instance_method(selector)
			Context.default.adapt_class(adapted_class, selector, default_method)
		end

		# If the context is active, we should activate the new adaptation
		if active? 
			manager.activate_adaptation(adaptation)
		end
	end
	
	# Return the adaptation for a selector method in a_class
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

	# Return whether this contexts adapts the selector method in a_class
	def adapts?(a_class, selector)
		@adaptations.each { |adapted| 
			if adapted.adapted_class == a_class and adapted.selector == selector
				return true
			end
		}	
		return false
	end
	
	# Is this context be active?
	def active?
		@activation_count > 0
	end

	# ToString, if the context has no name, it is Anonymous context
	def to_s
		if @name == nil
			return "Anonymous context"
		end

		return "#{@name} context" 
	end
end
