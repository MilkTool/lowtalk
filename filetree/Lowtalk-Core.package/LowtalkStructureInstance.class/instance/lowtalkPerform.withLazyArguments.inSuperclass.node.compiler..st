message dispatching
lowtalkPerform: selector withLazyArguments: arguments inSuperclass: superClass node: sendingNode compiler: aCompiler
	| precedence slot value valueType method |
	(selector == #class) ifTrue: [ ^ type ].
	
	method := type concreteMethodForSelector: selector.
	method ifNotNil: [
		^ method lowtalkValueWithArguments: { self } , (arguments collect: #value)
		types: {self type ref} , (arguments collect: #type) compiler: aCompiler at: sendingNode
	].
	
	precedence := selector precedence.
	precedence = 1 ifTrue: [ 
		type slotNamed: selector ifPresent: [ :slotDescription |
			^ slots at: slotDescription index + 1
		]
	].
	precedence = 3 ifTrue: [
		type slotNamed: selector allButLast ifPresent: [ :slotDescription |
			slot := slots at: slotDescription index + 1.
			value := arguments first value.
			valueType := arguments first inferType.
			slot value: (valueType convertValue: value toType: slot valueType at: sendingNode).
			^ slot
		]
	].

	^ super lowtalkPerform: selector withLazyArguments: arguments inSuperclass: superClass node: sendingNode compiler: aCompiler