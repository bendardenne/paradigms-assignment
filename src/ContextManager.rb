
require 'set'

class ContextManager 

	attr_reader :directory

	def initialize
		@directory = {} 
		@activeAdaptations = Set.new
	end

	def discard(context)
		@directory.delete(context.name)
	end	

	def activateAdaptation(adaptation)
		
		@activeAdaptations.each {|a| 
			if a.sameTarget? adaptation and a.context != Context.default
				raise ArgumentError, "Cannot activate #{adaptation}: 
					conflicts with activated adaptation #{a}"
			end}

		@activeAdaptations << adaptation
		adaptation.deploy
	end

	def deactivateAdaptation(adaptation)
		# Acquire default adaptation and activate it
		# TODO Fix when several Contexts
		
		@activeAdaptations.delete(adaptation)
		a = Context.default.getAdaptation(adaptation.adaptedClass, adaptation.selector)
		activateAdaptation(a)
	end
end
