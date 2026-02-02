extends ItemBase

func _init():
	id = "BirthControlPill"

func getVisibleName():
	return "Plan B Pill"
	
func getDescription():
	return "Works by delaying ovulation. Most effective when taken as soon as possible after unprotected sex. Does not work if ovulation has already occurred. Has a success rate of about 90%."

func canUseInCombat():
	return true

func useInCombat(_attacker, _receiver):
	var target = _attacker
	if(_receiver != null && _receiver.isPlayer()):
		target = _receiver

	if(target.getMenstrualCycle()):
		var cycleDays = target.getMenstrualCycle().getCycleLength() / (24.0 * 3600.0)
		var delaySeconds = (cycleDays / 5.0) * 24.0 * 3600.0
		if(target.getMenstrualCycle().delayOvulation(delaySeconds)):
			removeXOrDestroy(1)
			return _attacker.getName() + " took the Plan B pill. Ovulation was delayed."
		else:
			removeXOrDestroy(1)
			return _attacker.getName() + " took the Plan B pill. It seems it was too late or it just didn't work."
	removeXOrDestroy(1)
	return _attacker.getName() + " took the Plan B pill."

func getPossibleActions():
	return [
		{
			"name": "Consume",
			"scene": "UseItemLikeInCombatScene",
			"description": "Take the pill",
		},
	]

func getPrice():
	return 5

func canSell():
	return true

func canCombine():
	return true

func addsIntoxication():
	return 0.0

func getTimedBuffs():
	return []

func getBuffsDurationSeconds():
	return 0

func getTags():
	return [
		ItemTag.SoldByMedicalVendomat,
		ItemTag.SexEngineDrug,
		]

func getBuyAmount():
	return 1

func getSexEngineInfo(_sexEngine, _domInfo, _subInfo):
	return {
		"name": "Plan B pill",
		"usedName": "a Plan B pill",
		"desc": "Delays ovulation if taken in time.",
		"scoreOnSub": _domInfo.goalsScoreMax({SexGoal.FuckVaginal: 1.0, SexGoal.FuckAnal: 0.1}, _subInfo.charID)*_domInfo.fetishScore({Fetish.Breeding: -1.0}),
		"scoreOnSelf": _domInfo.goalsScoreMax({SexGoal.ReceiveVaginal: 1.0, SexGoal.ReceiveAnal: 0.1}, _subInfo.charID)*_domInfo.fetishScore({Fetish.BeingBred: -1.0}),
		"scoreSubScore": _subInfo.fetishScore({Fetish.BeingBred: -1.0}),
		"canUseOnDom": true,
		"canUseOnSub": true,
		"maxUsesByNPC": 1,
	}

func useInSex(_receiver):
	if(_receiver.getMenstrualCycle()):
		var cycleDays = _receiver.getMenstrualCycle().getCycleLength() / (24.0 * 3600.0)
		var delaySeconds = (cycleDays / 5.0) * 24.0 * 3600.0
		if(_receiver.getMenstrualCycle().delayOvulation(delaySeconds)):
			return {text = "{receiver.name} took the Plan B pill. Ovulation was delayed."}
		else:
			return {text = "{receiver.name} took the Plan B pill, but it didn't seem to work."}
	return {text = "{receiver.name} took the Plan B pill."}

func getItemCategory():
	return ItemCategory.Medical
