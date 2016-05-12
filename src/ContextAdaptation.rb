# This class is used to define a context adaptation "context" of a method "selector" in a class "adapted_class" with new implementation "method" 
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

	# To deploy the adaptation
	def deploy
		m = @method
		a = self

		# Deploy the new adaptation on the class
		@adapted_class.send(:define_method, @selector, lambda{|params = m.parameters, adaptation = a| 
			# Add the adaptation to proceeds stack 
			# to keep track of the adaptation that we are in currently
			ContextManager.instance.proceeds = ContextManager.instance.proceeds.push(adaptation)
			
			# Get an UnboundMethod to bind to the calling object
			if m.is_a? Method
				m.unbind
			elsif m.is_a? Proc
				## Dirty hack, avert your eyes
				Object.send(:define_method, :___fake_method_COP, &m)
				m = Object.instance_method(:___fake_method_COP)
			end	

			# At this point we have an UnboundMethod
			# Which we bind to the caller object (self) 
			# and then we call the implementation
			r = m.bind(self).call(*params)

			# Pop the adaptation from proceeds array after executing it 
			ContextManager.instance.proceeds.pop
			
			# Return the result of the adapting implementation
			r
		})
	end

	# Return true if the curret adaptation is adapting the method "selector" in "a_class"
	def adapts?(a_class, selector)
		self.adapted_class == a_class and self.selector == selector
	end

	# Return true if the "other" context adaptation adapts the same (method, class)
	# of this context adaptation
	def same_target?(other)
		other.adapted_class == @adapted_class and other.selector == @selector
	end

	# ToString function
	def to_s
		"#{@context}##{@adapted_class}:#{@selector}"
	end

end
