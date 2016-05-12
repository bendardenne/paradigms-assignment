module ContextModule

	# Handling the "proceed" missing method in class Phone 
	def method_missing(symbol, *args, &block)
		# If the missing method is "proceed"
		if symbol == :proceed
			# Call proceed from the context manager, passing the self (calling object) and the arguments as parameters
			return ContextManager.instance.proceed(self, *args)
		end	
		super(symbol, args, block)
	end
end
