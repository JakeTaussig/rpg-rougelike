extends Control
class_name Tracker

@export var is_player := false
var monster: Monster


func bind_monster(m: Monster, p: bool) -> void:
	monster = m
	is_player = p


func _ready():
	$Panel/TitleContainer/CharacterName.text = monster.character_name
	if is_player:
		populate_player_tracker()
	else:
		populate_enemy_tracker()


@export var show_funds := false


func populate_player_tracker():
	$Panel/TrackerInfo/HP.text = "%d/%d" % [monster.hp, monster.max_hp]
	$Panel/TrackerInfo/ATK.text = str(monster.atk)
	$Panel/TrackerInfo/SP_ATK.text = str(monster.sp_atk)
	$Panel/TrackerInfo/DEF.text = str(monster.def)
	$Panel/TrackerInfo/SP_DEF.text = str(monster.sp_def)
	$Panel/TrackerInfo/SPEED.text = str(monster.speed)
	$Panel/TrackerInfo/LUCK.text = str(monster.luck)
	$Panel/TrackerInfo/CRIT.text = "%2.0f" % (100.0 * monster.crit_chance) + "% " + "(%d)" % monster.crit_checks
	$Panel/TrackerInfo/ACC.text = str(monster.acc)
	_render_title_and_funds()


func populate_enemy_tracker():
	if GameManager.reveal_enemy_attacking_stats:
		$Panel/TrackerInfo/ATK.text = str(monster.atk)
		$Panel/TrackerInfo/SP_ATK.text = str(monster.sp_atk)
	if GameManager.reveal_enemy_defensive_stats:
		$Panel/TrackerInfo/DEF.text = str(monster.def)
		$Panel/TrackerInfo/SP_DEF.text = str(monster.sp_def)
	if GameManager.reveal_enemy_misc_stats:
		$Panel/TrackerInfo/SPEED.text = str(monster.speed)
		$Panel/TrackerInfo/LUCK.text = str(monster.luck)
		$Panel/TrackerInfo/CRIT.text = "%2.0f" % (100.0 * monster.crit_chance) + "% " + "(%d)" % monster.crit_checks
		$Panel/TrackerInfo/ACC.text = str(monster.acc)
	_render_title_and_funds()


func _render_title_and_funds():
	if show_funds:
		%Funds.show()
		%Funds.text = "¶ %d" % GameManager.player.prana
		%CharacterName.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT

	else:
		%Funds.hide()
		%CharacterName.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
