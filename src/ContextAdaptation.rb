require_relative 'MethodAdaptation'

class ContextAdaptation

	attr_accessor :context, :adapted_class, :selector, :method	

	def initialize(context, adapted_class, selector, method)
		@context = context
		@adapted_class = adapted_class
		@selector = selector
		@method = method
	end 

	def activation_age 
		@context.activation_age
	end

	def deploy
		m = @method
		a = self
		@adapted_class.send(:define_method, @selector, lambda{|params = m.parameters, adaptation = a| 
			ContextManager.instance.proceeds = 
			ContextManager.instance.proceeds.push(adaptation)
			
			if m.is_a? Method or m.is_a? Proc
				r = m.call(*params)
			else 
				r = m.bind(self).call(*params)
			end

			ContextManager.instance.proceeds.pop
			r
		})
	end

	def adapts?(a_class, selector)
		self.adapted_class == a_class and self.selector == selector
	end

	def same_target?(other)
		other.adapted_class == @adapted_class and other.selector == @selector
	end

	def to_s
		"#{@context}##{@adapted_class}:#{@selector}"
	end

end
