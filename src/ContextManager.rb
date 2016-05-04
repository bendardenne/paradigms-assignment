
require 'set'
require 'singleton'


class ContextManager 

	include Singleton

	attr_reader :directory
	attr_accessor :proceeds
	

	def initialize
		@directory = {} 
		@activeAdaptations = Array.new
		@proceeds = Array.new
	end

	def proceed(*args)
		current = @proceeds.last
		nextAdapt = nextAdaptation(current)
		
		nextAdapt.deploy
		r = current.adaptedClass.new.send(current.selector, args)	
		current.deploy
		r
	end

	def discard(context)
		@directory.delete(context.name)
	end	

	def activateAdaptation(adaptation)
		@activeAdaptations << adaptation
		adaptation.deploy
	end

	def deactivateAdaptation(adaptation)
		nextAdapt = nextAdaptation(adaptation)
		@activeAdaptations.delete(adaptation)
		nextAdapt.deploy
	end

	def nextAdaptation(current)
		@activeAdaptations.select {|a| 
			a.sameTarget? current and a != current}.last
	end

	def adaptationChain(aClass, selector)
	end
end
