
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
		@policy = lambda {|c1, c2| c1.activation_age <=> c2.activation_age}
	end

	def proceed(obj, *args)
		current = @proceeds.last
		next_adapt = adaptation_after(current)
		
		next_adapt.deploy
		r = obj.send(current.selector, args)	
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
		@active_adaptations.delete(adaptation)
		next_adapt = best_adaptation(adaptation.adapted_class, adaptation.selector)
		next_adapt.deploy
	end

	def adaptation_chain(aClass, selector)
		@active_adaptations.select {|a| 
			a.adapts? aClass, selector}.sort(&@policy)
	end

	def adaptation_after(current)
		first = adaptation_chain(current.adapted_class, current.selector)
			.drop_while{|x| x != current}[1]

		# Get default if no candidate adaptation available
		if first.nil? 
			first = Context.default.get_adaptation(current.adapted_class, current.selector)
		end
		first
	end

	def best_adaptation(aClass, selector)
		first = adaptation_chain(aClass, selector).first
		
		if first.nil? 
			first = Context.default.get_adaptation(aClass, selector)
		end
		first
	end
end
