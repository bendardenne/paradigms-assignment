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
		m = @method
		a = self
		@adaptedClass.send(:define_method, @selector, lambda{ |params = m.parameters, adaptation = a| 
			ContextManager.instance.proceeds = 
			ContextManager.instance.proceeds.push(adaptation)
			
			if m.is_a? Method or m.is_a? Proc
				r = m.call(params)
			else 
				r = m.bind(self).call(params)
			end

			ContextManager.instance.proceeds.pop
			r
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
