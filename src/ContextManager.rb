
require 'set'
require 'singleton'


class ContextManager 

	include Singleton

	# To store active contexts
	attr_reader :directory
	
	# proceed: array to store the adaptations in order, 
	# so we know which adaptation should be called when we have "proceed"
	# policy: to define the policy in which the manager will decide which adaptation should be called 
	attr_accessor :proceeds, :policy
	
	# Initialize the manager, with "age" as default policy 
	def initialize
		@directory = {} 
		@active_adaptations = Array.new
		@proceeds = Array.new
		@policy = lambda {|c1, c2| c1.activation_age <=> c2.activation_age}
	end

	# Deploy the next appropriate adaptation, and call in on obj with args
	def proceed(obj, *args)
		# The current adaptation is the last item in the "proceeds" stack
		current = @proceeds.last
		
		# The next adaptation is the one before the current 
		next_adapt = adaptation_after(current)
		
		# Deploy the proceed adaptation 
		next_adapt.deploy
		
		# Call the deployed adaptation on the caller object
		r = obj.send(current.selector.method, args)
		
		# Re-deploy the current again	
		current.deploy

		# Return the result of the proceed
		r
	end

	# To discard a context we simply delete it from the directory
	def discard(context)
		@directory.delete(context.name)
	end	

	def activate_adaptation(adaptation)
		# Add the new adaptation to the active_adaptations array 
		@active_adaptations << adaptation
		
		# Get the best adaptation to deploy according to 
		# the policy considering the newly added adaptation
		adapt = best_adaptation(adaptation.selector)
		
		# Deploy the best adaptation
		adapt.deploy
	end

	def deactivate_adaptation(adaptation)
		# Remove the adaptation from the active_adaptations array
		@active_adaptations.delete(adaptation)
		
		# Get the best adaptation to deploy after deactivating 
		next_adapt = best_adaptation(adaptation.selector)
		
		# Deploy the best one
		next_adapt.deploy
	end

	# Get a sorted chain (according to the policy) 
	# of all active adaptations for the 'selector' method in 'a_class'
	def adaptation_chain(selector)
		@active_adaptations.select {|a| a.adapts? selector}.sort(&@policy)
	end

	# Returns the adaptation which is after 'current' in the chain
	def adaptation_after(current)
		first = adaptation_chain(current.selector)
			.drop_while{|x| x != current}[1]

		# Get default if no candidate adaptation available
		if first.nil? 
			first = Context.default.get_adaptation(current.selector)
		end
		first
	end

	# Getting the best adaptation to deploy according to the policy
	def best_adaptation(selector)

		# It is the first one in the ordered chain
		first = adaptation_chain(selector).first
		
		# Or the default if the chain is empty (no active adaptations for this method)
		if first.nil? 
			first = Context.default.get_adaptation(selector)
		end
		first
	end
end
