*Lowtalk-IDE
gtInspectorLowtalkIn: composite
	<gtInspectorPresentationOrder: 0>
	(#('ltk' 'lowtalk') includes: self extension)
		ifFalse: [ ^ self ].
	
	^ composite custom: (GLMRubricHighlightedTextPresentation new
		title: 'Lowtalk';
		editingMode: [ : rubPresentation |
			GLMHighlighterTextRubEditingMode withStylerDecorator: (
				LowtalkHighlighterTextDecorator 
					inPresentation: rubPresentation
					fileReference: self)];
		display: [ self readStreamDo: #contents ];
		act: [:rub | 
			self 
				ensureDelete; 
				writeStreamDo: [ :s | s nextPutAll: rub text asString ]] 
			icon: GLMUIThemeExtraIcons glamorousSave 
			on: $s
			entitled: 'Save')