
require 'set'
require 'singleton'


class ContextManager 

	include Singleton

	attr_reader :directory
	attr_accessor :proceeds, :policy
	

	def initialize
		@directory = {} 
		@active_adaptations = Array.new
		@proceeds = Array.new
		@policy = lambda {|c1, c2| c2.activation_age <=> c1.activation_age}
	end

	def proceed(*args)
		current = @proceeds.last
		next_adapt = next_adaptation(current)
		
		next_adapt.deploy
		r = current.adapted_class.new.send(current.selector, args)	
		current.deploy
		r
	end

	def discard(context)
		@directory.delete(context.name)
	end	

	def activate_adaptation(adaptation)
		@active_adaptations << adaptation
		
		adapt = best_adaptation(adaptation.adapted_class, adaptation.selector)
		adapt.deploy
	end

	def deactivate_adaptation(adaptation)
		next_adapt = next_adaptation(adaptation)
		@active_adaptations.delete(adaptation)
		next_adapt.deploy
	end

	def next_adaptation(current)
		first = @active_adaptations.select {|a| 
			a.same_target? current and a != current}.sort(&@policy).first

		# Get default if not available candidate adaptation
		if first.nil? 
			first = Context.default.get_adaptation(current.adapted_class, current.selector)
		end
		first
	end

	def best_adaptation(aClass, selector)
		@active_adaptations.select {|a| 
			a.adapts? aClass, selector}.sort(&@policy).first
	end
end
