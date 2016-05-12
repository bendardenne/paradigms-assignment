#!/usr/bin/env ruby

require 'set'


# Adding the required modules
require_relative 'ContextManager'
require_relative 'ContextAdaptation'

ClassSelector = Struct.new(:a_class, :method)

class Context


	# multiple_activation: If it is allowed to activate this context multible times or not  
	attr_reader :manager, :multiple_activation
	attr_accessor :name

	# Class variable to store the default context
	@@default = nil
	# Class variable to store the current age (used in the policy)
	@@age = 0

	
	def initialize(name = nil, multiple_activation: true)
		@activation_count = 0
		@activation_age = 0
		@adaptations = Set.new
		@multiple_activation = multiple_activation
		@name = name
		@manager = ContextManager.instance
		@manager.register(self)
	end


	# Get the default context. If it is not created yet, 
	# a default context will be created and activated
	def self.default 
		if @@default == nil
			@@default = Context.new("default")
			@@default.activate
		end

		return @@default
	end	

	# Set the default manually
	def self.default=(newDefault)
		@@default = newDefault
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
		@activation_count -= 1 if @activation_count > 0

		# After decreasing the count, if it is 0, we should deactivate the context adaptations
		deactivate_adaptations if not active? 
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
	def adapt_class(adapted_class, method_selector, implementation)
		
		selector = ClassSelector.new(adapted_class, method_selector)

		# Make sure this context isn't already adapting the same method before
		raise ArgumentError, "#{self} already adapts #{selector}" if adapts? selector
		
		# Create the new adaptation and add it to the adaptations set
		adaptation = ContextAdaptation.new(self, selector, implementation)	
		@adaptations << adaptation							 

		# if the default has no implementation for the method, 
		# we store the current implementation in the default
		if not Context.default.adapts?(selector)
			default_method = adapted_class.instance_method(method_selector)
			Context.default.adapt_class(adapted_class, method_selector, default_method)
		end

		# If the context is active, we should activate the new adaptation
		manager.activate_adaptation(adaptation) if active?
	end
	
	# Return the adaptation for a selector
	def get_adaptation(selector)
		@adaptations.each{|a| return a if a.selector == selector }

		raise ArgumentError, "#{selector} is not adapted by #{self}"
	end

	##############
	# PREDICATES #	
	##############

	# Return whether this contexts adapts this selector
	def adapts?(selector)
		@adaptations.each { |adapted| 
			return true if adapted.selector == selector
		}	
		return false
	end
	
	# Is this context be active?
	def active?
		@activation_count > 0
	end

	# ToString, if the context has no name, it is Anonymous context
	def to_s
		return "Anonymous context" if @name == nil
		
		return "#{@name} context" 
	end
end
