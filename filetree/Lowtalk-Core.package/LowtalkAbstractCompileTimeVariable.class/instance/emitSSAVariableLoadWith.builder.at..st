code generation
emitSSAVariableLoadWith: codeGenerator builder: builder at: node
	^ compiler convertDynamicObjectSSAConstant: binding value.