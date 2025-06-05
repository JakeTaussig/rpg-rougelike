extends HSplitContainer


@export var participant: BattleParticipant

func _ready():
	call_deferred("update_offset")

func update_offset():
	var min = position.x - (size.x)/2
	var max = position.x + (size.x)/2 + 1
	var factor: float = float(participant.selected_monster.hp) / float(participant.selected_monster.max_hp)
	split_offset = (factor * max) + ((1 - factor) * min)
