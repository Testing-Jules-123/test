extends ItemBase

func _init():
	id = "DailyBirthControlPill"

func getVisibleName():
	return "Daily Birth Control Pills"

func getDescription():
	return "Take one every 24 hours to prevent ovulation. It takes some time to become fully effective (about a quarter of your cycle length). If you miss a dose for more than 36 hours, it becomes ineffective and you must start over."

func canUseInCombat():
	return true

func useInCombat(_attacker, _receiver):
	_receiver.addEffect(StatusEffect.DailyBirthControl)
	var effect = _receiver.getEffect(StatusEffect.DailyBirthControl)
	if(effect):
		effect.takePill()
	removeXOrDestroy(1)
	return _attacker.getName() + " took a birth control pill"

func getPossibleActions():
	return [
		{
			"name": "Consume",
			"scene": "UseItemLikeInCombatScene",
			"description": "Take a pill",
		},
	]

func getPrice():
	return 2

func canSell():
	return true

func canCombine():
	return true

func addsIntoxication():
	return 0.0

func getTags():
	return [
		ItemTag.SoldByMedicalVendomat,
		ItemTag.SexEngineDrug,
		]

func getBuyAmount():
	return 14

func getSexEngineInfo(_sexEngine, _domInfo, _subInfo):
	return {
		"name": "Daily birth control pill",
		"usedName": "a birth control pill",
		"desc": "Prevents ovulation when taken regularly.",
		"scoreOnSub": 0.0,
		"scoreOnSelf": 0.0,
		"canUseOnDom": true,
		"canUseOnSub": true,
		"maxUsesByNPC": 1,
	}

func useInSex(_receiver):
	_receiver.addEffect(StatusEffect.DailyBirthControl)
	var effect = _receiver.getEffect(StatusEffect.DailyBirthControl)
	if(effect):
		effect.takePill()

func getItemCategory():
	return ItemCategory.Medical
