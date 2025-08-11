extends Control
class_name Tracker

@export var is_player := false
var monster: Monster


func bind_monster(m: Monster, p: bool) -> void:
	monster = m
	is_player = p


func _ready():
	if is_player:
		populate_player_tracker()
	else:
		$Panel/TrackerInfo/Placeholder/Character_Name.text = monster.character_name


func populate_player_tracker():
	$Panel/TrackerInfo/Placeholder/Character_Name.text = monster.character_name
	$Panel/TrackerInfo/HP.text = "%d/%d" % [monster.hp, monster.max_hp]
	$Panel/TrackerInfo/ATK.text = str(monster.atk)
	$Panel/TrackerInfo/SP_ATK.text = str(monster.sp_atk)
	$Panel/TrackerInfo/DEF.text = str(monster.def)
	$Panel/TrackerInfo/SP_DEF.text = str(monster.sp_def)
	$Panel/TrackerInfo/SPEED.text = str(monster.speed)
	$Panel/TrackerInfo/LUCK.text = str(monster.luck)
	$Panel/TrackerInfo/CRIT.text ="%2.0f" % (100.0 * monster.crit_chance) + "% " + "(%d)" % monster.crit_checks
	$Panel/TrackerInfo/ACC.text = str(monster.acc)


func populate_enemy_tracker():
	$Panel/TrackerInfo/Placeholder/Character_Name.text = GameManager.enemy.selected_monster.character_name
