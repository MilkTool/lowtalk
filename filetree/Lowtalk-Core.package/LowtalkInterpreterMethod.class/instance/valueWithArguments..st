evaluating
valueWithArguments: evaluationArguments
	^ self lowtalkValueWithArguments: evaluationArguments types: (evaluationArguments collect: [:arg | arg lowtalkLiteralTypeWith: environment compiler]) compiler: environment compiler at: LowtalkASTNode new.