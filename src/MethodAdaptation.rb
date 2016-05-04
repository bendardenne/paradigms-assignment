module MethodAdaptation
	
	refine UnboundMethod do
		attr_accessor :adaptation
	end

	def method_missing(name, *args, &body) 
		# Get adapter method name and call the corresponding proceed method
		source = caller_locations(1,1)[0].base_label
		self.send("proceed_#{source}", args)
	end

end
