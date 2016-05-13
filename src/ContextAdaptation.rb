
require_relative 'Context'

class ContextAdaptation

	attr_accessor :context, :adapted_class, :selector, :method	

	def initialize(context, selector, method)
		@context = context
		@selector = selector
		@method = method

		# Add the proceed method in the adapted class
		# This method can be called by adapting methods to pass
		# control to previous adaptations
		@selector.a_class.class_eval("
			def proceed(*args) 
				return ContextManager.instance.proceed(self, args)
			end")
	end 

	def activation_age 
		@context.activation_age
	end

	# To deploy the adaptation
	def deploy
		m = @method
		a = self

		# Get an UnboundMethod to bind to the calling object
		if m.is_a? Method
			m.unbind
		elsif m.is_a? Proc
			## Dirty hack, avert your eyes
			Object.send(:define_method, :___fake_method_COP, &m)
			m = Object.instance_method(:___fake_method_COP)
			Object.send(:remove_method, :___fake_method_COP)
		end	

		# Deploy the new adaptation on the class
		@selector.a_class.send(:define_method, @selector.method,
			 lambda{|*args| 
				# Add the adaptation to proceeds stack 
				# to keep track of the adaptation that we are in currently
				ContextManager.instance.proceeds.push(a)
				
				# The UnboundMethod is bounnd to the caller object (self) 
				# then called with the given parameters
				r = m.bind(self).call(*args)

				# Pop the adaptation from proceeds stack after executing it 
				ContextManager.instance.proceeds.pop
				
				# Return the result of the adapting implementation
				r
			})
	end

	# Return true if the curret adaptation is adapting the method "selector" in "a_class"
	def adapts?(selector)
		@selector == selector
	end

	# Return true if the "other" context adaptation adapts the same (method, class)
	# of this context adaptation
	def same_target?(other)
		other.selector == @selector
	end

	# ToString function
	def to_s
		"#{@context}##{@selector}"
	end

end
