require_relative 'MethodAdaptation'

class ContextAdaptation

	using MethodAdaptation

	attr_accessor :context, :adaptedClass, :selector, :method	

	def initialize(context, adaptedClass, selector, method)
		@context = context
		@adaptedClass = adaptedClass
		@selector = selector
	 	@method = method
	end 


	def deploy
		@adaptedClass.send(:alias_method, "proceed_#{@method.name}", @selector)
		@adaptedClass.send(:define_method, @selector, @method)
	end

	def adapts?(aClass, selector)
		self.adaptedClass == aClass and self.selector == selector
	end

	def sameTarget?(other)
		other.adaptedClass == @adaptedClass and other.selector == @selector
	end

	def active?
		@adaptedClass.instance_method(@selector) == @method
	end

	def to_s
		"#{context}##{adaptedClass}:#{selector}"
	end

end
