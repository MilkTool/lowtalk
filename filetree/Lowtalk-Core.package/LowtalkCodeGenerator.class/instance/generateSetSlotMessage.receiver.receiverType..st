messages
generateSetSlotMessage: message receiver: receiver receiverType: receiverType
	| referenceType structureType slot structurePointer slotPointer newValue newValueType |
	self assert: message arguments size = 1.
	structurePointer := receiver.
	referenceType := receiverType.
	structureType := referenceType withoutReferences.
	
	"Make sure we have a pointer to the structure."
	self assert: structureType isStructureType.
	referenceType isReferenceType ifFalse: [
		self assert: referenceType isStructureType.
		structurePointer := allocaBuilder alloca: structureType ssaType.
		builder store: receiver in: structurePointer
	].
	
	"Get the slot pointer"
	slot := structureType slotNamed: message selector allButLast.
	
	"Conver the slot value"
	newValue := message arguments first accept: self.
	newValueType := message arguments first type.
	newValue := self coerceImplicitly: newValue type: newValueType to: slot type at: message.

	"Set the slot value"	
	slotPointer := builder getReference: structurePointer element: (builder constInt: slot index).
	builder store: newValue in: slotPointer.
	
	"Return the slot pointer"
	^ slotPointer