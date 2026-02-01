extends "res://Characters/Dynamic/Generator/CharacterGeneratorBase.gd"

func generateForChild(child):
	var mother = GlobalRegistry.getCharacter(child.motherID)
	var father = GlobalRegistry.getCharacter(child.fatherID)

	var args = {}
	args[NpcGen.Gender] = child.gender
	args[NpcGen.Name] = child.name
	args[NpcGen.Species] = child.species[0] if child.species.size() > 0 else "canine"

	var character = makeBase("child", args)
	character.npcCharacterType = CharacterType.Inmate # So they can be found in the prison
	character.npcGeneratedGender = child.gender
	character.npcName = child.name
	character.npcSpecies = child.species

	# Description
	if (child.motherID == "pc" || child.fatherID == "pc"):
		character.npcSmallDescription = "One of your children"
	else:
		var motherName = mother.getName() if mother != null else child.getMotherName()
		character.npcSmallDescription = "One of " + motherName + "'s children"

	# Traits inheritance
	if (mother != null):
		# Skin type
		if (father != null && RNG.chance(20)):
			character.pickedSkin = father.pickedSkin
		else:
			character.pickedSkin = mother.pickedSkin

		# Colors
		if (father != null):
			character.pickedSkinRColor = mother.pickedSkinRColor.linear_interpolate(father.pickedSkinRColor, 0.5)
			character.pickedSkinGColor = mother.pickedSkinGColor.linear_interpolate(father.pickedSkinGColor, 0.5)
			character.pickedSkinBColor = mother.pickedSkinBColor.linear_interpolate(father.pickedSkinBColor, 0.5)
		else:
			character.pickedSkinRColor = mother.pickedSkinRColor
			character.pickedSkinGColor = mother.pickedSkinGColor
			character.pickedSkinBColor = mother.pickedSkinBColor

		# Thickness and Femininity
		if (father != null):
			character.npcThickness = (mother.getThickness() + father.getThickness()) / 2
			character.npcFeminity = (mother.getFemininity() + father.getFemininity()) / 2
		else:
			character.npcThickness = mother.getThickness()
			character.npcFeminity = mother.getFemininity()

	# Body parts inheritance
	var theSpecies:Array = character.npcSpecies
	for bodypartSlot in BodypartSlot.getAll():
		var motherPart = mother.getBodypart(bodypartSlot) if (mother != null && mother.hasBodypart(bodypartSlot)) else null
		var fatherPart = father.getBodypart(bodypartSlot) if (father != null && father.hasBodypart(bodypartSlot)) else null

		var pickedPart = null
		if (motherPart != null && fatherPart != null):
			pickedPart = motherPart if RNG.chance(50) else fatherPart
		elif (motherPart != null):
			pickedPart = motherPart
		elif (fatherPart != null):
			pickedPart = fatherPart

		var possibleIDs = Bodypart.findPossibleBodypartIDsDict(bodypartSlot, character, theSpecies, character.npcGeneratedGender)

		if (pickedPart != null && possibleIDs.has(pickedPart.id)):
			var newBodypart = GlobalRegistry.createBodypart(pickedPart.id)
			character.giveBodypartUnlessSame(newBodypart)

			var skinData = pickedPart.getSkinData()
			if(skinData.has("skin")):
				newBodypart.pickedSkin = skinData["skin"]
			if(skinData.has("r")):
				newBodypart.pickedRColor = skinData["r"]
			if(skinData.has("g")):
				newBodypart.pickedGColor = skinData["g"]
			if(skinData.has("b")):
				newBodypart.pickedBColor = skinData["b"]
		else:
			# Fallback to random if parent's part is not compatible or neither has it
			var possibleAr = Bodypart.findPossibleBodypartIDs(bodypartSlot, character, theSpecies, character.npcGeneratedGender)
			var fullWeight:float = 0.0
			for pairs in possibleAr:
				fullWeight += max(0.0, pairs[1])

			if(possibleAr.size() > 0 && RNG.chance(fullWeight * 100.0)):
				var bodypartID = RNG.pickWeightedPairs(possibleAr)
				if(bodypartID != null && bodypartID != ""):
					var bodypart = GlobalRegistry.createBodypart(bodypartID)
					if(bodypart):
						character.giveBodypartUnlessSame(bodypart)
						bodypart.generateDataFor(character)

	# The rest (level, stats, archetypes, personality, fetishes, lust, etc)
	pickLevel(character, args)
	pickStats(character, args)
	pickArchetypes(character, args)
	pickAttacks(character, args)
	pickFetishes(character, args)
	pickLustInterests(character, args)
	pickPersonality(character, args)
	applyArgs(character, args)
	pickEquipment(character, args)

	character.resetEquipment()
	resetStats(character, args)
	pickNonStaticEquipment(character, args)

	for species in character.getSpecies():
		var speciesObject = GlobalRegistry.getSpecies(species)
		if(speciesObject != null):
			speciesObject.onDynamicNpcCreation(character, args)

	character.updateNonBattleEffects()

	child.npcID = character.getID()
	if(is_instance_valid(GM.main)):
		GM.main.addDynamicCharacterToPool(character.getID(), CharacterPool.Inmates)

	return character
