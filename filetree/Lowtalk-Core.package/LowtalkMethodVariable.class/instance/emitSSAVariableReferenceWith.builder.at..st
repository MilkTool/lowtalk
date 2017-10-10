code generation
emitSSAVariableReferenceWith: codeGenerator builder: builder at: node
	self assert: ssaValue isNotNil.
	method ~~ codeGenerator method ifTrue: [
		^ codeGenerator captureInClosure: ssaValue
	].

	^ ssaValue