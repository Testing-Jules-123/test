extends StatusEffectBase

var timePassed = 0.0

func _init():
	id = StatusEffect.IUD
	isSexEngineOnly = false

func getEffectName():
	return "Intrauterine Device (IUD)"

func getEffectDesc():
	return "An old-school intrauterine device is implanted in your womb. It is highly effective at preventing pregnancy, but causes discomfort during menstruation."

func getEffectImage():
	return "res://Images/StatusEffects/womb2.png"

func getIconColor():
	return IconColorPurple

func getBuffs():
	return [
		buff(Buff.FinalFertilityModifierBuff, [-99.99]),
	]

func processTime(_secondsPassed: int):
	if(!character || !character.getMenstrualCycle()):
		return

	if(character.getMenstrualCycle().getCurrentStage() == CycleStage.Menstruation):
		timePassed += _secondsPassed
		if(timePassed >= 3600.0):
			var painToAdd = floor(timePassed / 3600.0)
			character.addPain(int(painToAdd))
			timePassed -= painToAdd * 3600.0
	else:
		timePassed = 0.0

func saveData():
	return {
		"timePassed": timePassed,
	}

func loadData(_data):
	timePassed = SAVE.loadVar(_data, "timePassed", 0.0)
