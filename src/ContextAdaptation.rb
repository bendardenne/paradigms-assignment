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
		@adapted_class.sen(:define_method, @selector, lambda{|params = m.parameters, adaptation = a| 
			ContextManager.instance.proceeds = 
			ContextManager.instance.proceeds.push(adaptation)
			
			# Get an UnboundMethod to bind to the calling object
			if m.is_a? Method
				m.unbind
			elsif m.is_a? Proc
				## Dirty hack, avert your eyes
				Object.send(:define_method, :___fake_method_COP, &m)
				m = Object.instance_method(:___fake_method_COP)
			end	

			r = m.bind(self).call(*params)
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
