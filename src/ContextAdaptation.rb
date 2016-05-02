class ContextAdaptation

	attr_accessor :context, :adaptedClass, :selector, :method	

	def initialize(context, adaptedClass, selector, method)
		@context = context
		@adaptedClass = adaptedClass
		@selector = selector
		@method = method
	end 


	def deploy
		@adaptedClass.send(:define_method, @selector, @method)
	end

	def sameTarget?(other)
		other.adaptedClass == @adaptedClass and other.selector == @selector
	end

	def to_s
		"#{context}##{adaptedClass}:#{selector}"
	end

end
