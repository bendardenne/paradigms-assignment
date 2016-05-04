
require 'set'

class ContextManager 

	attr_reader :directory

	class << self
		attr_accessor :current_adaptation
	end

	def initialize
		@directory = {} 
		@activeAdaptations = Array.new
	end

	def discard(context)
		@directory.delete(context.name)
	end	

	def activateAdaptation(adaptation)
		
		@activeAdaptations << adaptation
		adaptation.deploy
	end

	def deactivateAdaptation(a)
		@activeAdaptations.delete(a)
		previous = adaptationChain(a.adaptedClass, a.selector).first
		previous.deploy
	end

	def adaptationChain(aClass, selector)
		@activeAdaptations.select{|a| a.adapts? aClass, selector}
	end
end
