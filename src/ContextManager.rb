
require 'set'
require 'singleton'


class ContextManager 

	include Singleton

	attr_reader :directory
	attr_accessor :proceeds
	

	def initialize
		@directory = {} 
		@active_adaptations = Array.new
		@proceeds = Array.new
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
		adaptation.deploy
	end

	def deactivate_adaptation(adaptation)
		next_adapt = next_adaptation(adaptation)
		@active_adaptations.delete(adaptation)
		next_adapt.deploy
	end

	def next_adaptation(current)
		last = @active_adaptations.select {|a| 
			a.same_target? current and a != current}.last

		# Get default if not available candidate adaptation
		if last.nil? 
			last = Context.default.get_adaptation(current.adapted_class, current.selector)
		end
		last
	end
end
