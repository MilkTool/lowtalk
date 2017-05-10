messages
generateRangeLoopMessage: message
	| startValue startType coercionType startCoercedValue increment incrementValue stop stopValue loopVariable loopHeader loopBody loopMerge iterationValue condition branch positiveIncrement positiveComparisonBlock negativeComparisonBlock incrementComparisonMerge incrementSignBranch positiveComparisonResult negativeComparisonResult |
	startType := message receiver type withoutReferences.
	startValue := self coerceImplicitly: (message receiver accept: self) type: message receiver type to: startType at: message.
	
	coercionType := message coercionType.
	startCoercedValue := self coerceImplicitly: startValue type: startType to: coercionType at: message.
	
	stop := message arguments first.
	stopValue := self coerceImplicitly: (stop accept: self) type: stop type to: coercionType at: message.

	message arguments size = 3 ifTrue: [ 
		increment := message arguments second.
		incrementValue := self coerceImplicitly: (increment accept: self) type: increment type to: coercionType at: message.
	] ifFalse: [
		incrementValue := self coerceImplicitly: 1 type: compiler integerLiteralType to: coercionType at: message.
	].

	loopVariable := allocaBuilder alloca: coercionType ssaType.
	builder store: startCoercedValue in: loopVariable.
	
	"The loop blocks"
	loopHeader := builder newBasicBlock: #toDoCondition.
	loopBody := builder newBasicBlock: #toDoBody.
	loopMerge := builder newBasicBlock: #toDoMerge.
	
	"Enter into the loop."
	builder jump: loopHeader.
	builder currentBlock: loopHeader.
	iterationValue := builder load: loopVariable.
	incrementValue isConstantValue ifTrue: [ 
		incrementValue value = 0 ifTrue: [ message semanticError: '#to:do:by increment cannot be zero.' ].
		incrementValue value < 0 ifTrue: [ 
			condition := self emitComparison: #>= left: iterationValue right: stopValue type: coercionType at: message.	
		] ifFalse: [ 
			condition := self emitComparison: #<= left: iterationValue right: stopValue type: coercionType at: message.	
		]
	] ifFalse: [
		"Check the increment sign"
		positiveIncrement := self emitComparison: #>= left: incrementValue right: (self coerceImplicitly: 0 type: compiler integerLiteralType to: coercionType at: message) type: coercionType at: message.
		positiveComparisonBlock := builder newBasicBlock: #positiveIncrementComparison.
		negativeComparisonBlock := builder newBasicBlock: #negativeIncrementComparison.
		incrementComparisonMerge := builder newBasicBlock: #incrementComparisonMerge.
		incrementSignBranch := builder branch: positiveIncrement ifTrue: positiveComparisonBlock ifFalse: negativeComparisonBlock.
		incrementSignBranch mergeBlock: incrementComparisonMerge.
		
		"Positive increment"
		builder currentBlock: positiveComparisonBlock.
		positiveComparisonResult := self emitComparison: #<= left: iterationValue right: stopValue type: coercionType at: message.
		builder jump: incrementComparisonMerge.
		
		"Negative increment"
		builder currentBlock: negativeComparisonBlock.
		negativeComparisonResult := self emitComparison: #>= left: iterationValue right: stopValue type: coercionType at: message.
		builder jump: negativeComparisonResult.
		
		builder currentBlock: incrementComparisonMerge.
		condition := builder phi: builder boolType.
		condition
			addValue: positiveComparisonResult from: positiveComparisonBlock;
			addValue: negativeComparisonResult from: negativeComparisonBlock.
	].
	
	branch := builder branch: condition ifTrue: loopBody ifFalse: loopMerge.
	
	"Emit the body"
	builder currentBlock: loopBody.
	self inlineBlock: message arguments last arguments:  {iterationValue} types: { coercionType }.
	
	"Increment"
	builder isLastTerminator ifFalse: [
		builder store: (self emitArithmetic: #+ left: iterationValue right: incrementValue type: coercionType at: message) in: loopVariable.
		builder jump: loopHeader
	].

	"Merge"
	builder currentBlock: loopMerge.
		
	^ startValue