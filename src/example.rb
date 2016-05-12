#!/usr/bin/env ruby

Dir["Phone/*.rb"].each {|file| require_relative file }
require_relative "Context"


phone = Phone.new("Bob")


#### Entering Hospital
	# Don't ring in the hospital
	quiet = Context.new("Quiet")

	# Overriding method can be acquired from a module
	quiet.adapt_class(Phone, :advertise,
		DiscreetPhone.instance_method(:advertise_quietly))		
	quiet.activate



#### Entering meeting room
	# Context can be activated multiple times ...
	quiet.activate
 


#### Leaving meeting room
	# ... and remain active unless deactivate is called as many times
	# as activate was called
	quiet.deactivate



#### Activate Screening
	screening = Context. new("screening")

	require_relative "ContextModule"
	include ContextModule

	# Context can adapt different methods
	screening.adapt_class(Phone, :receive, 
		ScreeningPhone.instance_method(:advertise_screening))		
	screening.activate


#### Receive call 
	call = PhoneCall.new
	# Overriding method (advertise_screening) can use proceed to call
	# the overriden method and use their return value.
	puts phone.receive(call)		# Vibrate with screening



#### Leave Hospital
	# Contexts can be deactivated in any order
	# Now, only screening is active
	quiet.deactivate


#### Enter car
	bluetooth = Context.new("bluetooth")

	# Overriding methods may access instance variables from the overriden class
	module Bluetooth
		def advertise_bluetooth(call)
			"#{proceed(call)} for #{@owner} over bluetooth" 
		end
	end

	# Proceeds may be chained
	bluetooth.adapt_class(Phone, :receive, 
		Bluetooth.instance_method(:advertise_bluetooth))

	bluetooth.activate
	puts phone.receive(call)


#### Driver says "Phone on low volume" 
	# Overriding methods may be given directly as a lambda
	low_volume = Context.new("low volume")
	low_volume.adapt_class(Phone, :advertise, lambda{|call| "Low ringtone"})
	low_volume.activate

	puts phone.receive(call)

	
	bluetooth.deactivate
	screening.deactivate
	low_volume.deactivate


#### The next day

	# Context oredring policy may be changed
	# Use oldest activated context (instead of newest by default)
	origPolicy = Context.default.manager.policy
	Context.default.manager.policy = lambda {|x,y| 
		y.activation_age <=> x.activation_age }
	
	Context.default.deactivate
	quiet.activate 
	Context.default.activate	# Default activated after quiet
	puts phone.advertise(call)	# Quiet is the current adaptation
	

#### Context adapting itself 

	Context.default.manager.policy = origPolicy 
	context = Context.new()

	module MyOwnContext
		def activate(multiple_adaptation)
			@activation_count = 1 
			@activation_age = Context.class_eval("@@age += 1") 
			activate_adaptations
		end
	end

	context.adapt_class(Context, :activate, MyOwnContext.instance_method(:activate))
	5.times { context.activate }
	puts context.active?	

	context.deactivate
	puts context.active?	

