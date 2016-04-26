

class ContextManager 

	attr_reader :directory

	def initialize
		@directory = {} 
	end

	def discard(context)
		@directory.delete(context.name)
	end
		

end
