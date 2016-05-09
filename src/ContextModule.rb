module ContextModule

	def method_missing(symbol, *args, &block)
		if symbol == :proceed
			return ContextManager.instance.proceed(self, *args)
		end	
		super(symbol, args, block)
	end
end
