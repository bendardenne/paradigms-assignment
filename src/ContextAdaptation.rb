require_relative 'MethodAdaptation'

class ContextAdaptation

	attr_accessor :context, :adaptedClass, :selector, :method	

	def initialize(context, adaptedClass, selector, method)
		@context = context
		@adaptedClass = adaptedClass
		@selector = selector
		@method = method
	end 


	def deploy
		@adaptedClass.send(:define_method, @selector, lambda{ |*args| 
			ContextManager.proceeds = ContextManager.proceeds.push(self)
			@method.call(args)
			ContextManager.proceeds.pop
		})
	end

	def adapts?(aClass, selector)
		self.adaptedClass == aClass and self.selector == selector
	end

	def sameTarget?(other)
		other.adaptedClass == @adaptedClass and other.selector == @selector
	end

	def to_s
		"#{context}##{adaptedClass}:#{selector}"
	end

end
