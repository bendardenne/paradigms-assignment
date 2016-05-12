module ContextModule

	def proceed(*args)
			return ContextManager.instance.proceed(self, *args)
	end		

	# Handling the "proceed" missing method  
#	def method_missing(symbol, *args, &block)
#		
#		# If the missing method is "proceed"
#		if symbol == :proceed
#			# Call proceed from the context manager, 
#			# passing the self (calling object) and the arguments as parameters
#			return ContextManager.instance.proceed(self, *args)
#		end	
#
#		# If not proceed, we let Ruby handle the missing method 
#		super(symbol, args, block)
#	end
end
