extends StatusEffectBase

var daysTaken = 0.0
var lastDoseTime = 0.0

func _init():
	id = StatusEffect.DailyBirthControl
	isSexEngineOnly = false

func initArgs(_args = []):
	if(_args.size() > 0):
		daysTaken = _args[0]
	if(_args.size() > 1):
		lastDoseTime = _args[1]

func takePill():
	var currentTime = GM.main.getDays() * 24 * 3600 + GM.main.getTime()
	if(lastDoseTime > 0 && (currentTime - lastDoseTime) > 36 * 3600):
		daysTaken = 1.0
	else:
		if(currentTime - lastDoseTime > 12 * 3600 || lastDoseTime == 0):
			daysTaken += 1.0

	var maxDays = getRequiredDays()
	if(daysTaken > maxDays):
		daysTaken = maxDays
	lastDoseTime = currentTime

func getRequiredDays():
	var cycleDays = 28.0
	if(character && character.getMenstrualCycle()):
		cycleDays = character.getMenstrualCycle().getCycleLength() / (24.0 * 3600.0)
	else:
		cycleDays = OPTIONS.getMenstrualCycleLengthDays()

	return max(1.0, cycleDays / 4.0)

func getEffectiveness():
	return clamp(daysTaken / getRequiredDays(), 0.0, 1.0)

func processTime(_secondsPassed: int):
	var currentTime = GM.main.getDays() * 24 * 3600 + GM.main.getTime()
	if(lastDoseTime > 0 && (currentTime - lastDoseTime) > 36 * 3600):
		daysTaken = 0.0

	if(daysTaken <= 0.0 && lastDoseTime > 0 && (currentTime - lastDoseTime) > 48 * 3600):
		stop()

func getEffectName():
	return "Daily Birth Control"

func getEffectDesc():
	var eff = getEffectiveness()
	if(eff >= 1.0):
		return "You are taking birth control pills regularly. They are fully effective."
	if(eff <= 0.0):
		return "You missed too many doses. The birth control is no longer effective."
	return "You are starting on birth control pills. Effectiveness: " + str(Util.roundF(eff * 100.0, 1)) + "%"

func getEffectImage():
	return "res://Images/StatusEffects/medicines.png"

func getIconColor():
	if(getEffectiveness() >= 1.0):
		return IconColorGreen
	return IconColorBlue

func isDrugEffect() -> bool:
	return true

func saveData():
	return {
		"daysTaken": daysTaken,
		"lastDoseTime": lastDoseTime,
	}

func loadData(_data):
	daysTaken = SAVE.loadVar(_data, "daysTaken", 0.0)
	lastDoseTime = SAVE.loadVar(_data, "lastDoseTime", 0.0)
