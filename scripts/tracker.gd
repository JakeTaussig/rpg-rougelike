extends Control
class_name Tracker

@export var is_player := true

@export var show_funds := false


func populate_player_tracker():
	$Panel/TrackerInfo/TitlePlaceholder/Character_Name.text = GameManager.player.selected_monster.character_name
	$Panel/TrackerInfo/HP.text = "%d/%d" % [GameManager.player.selected_monster.hp, GameManager.player.selected_monster.max_hp]
	$Panel/TrackerInfo/ATK.text = str(GameManager.player.selected_monster.atk)
	$Panel/TrackerInfo/SP_ATK.text = str(GameManager.player.selected_monster.sp_atk)
	$Panel/TrackerInfo/DEF.text = str(GameManager.player.selected_monster.def)
	$Panel/TrackerInfo/SP_DEF.text = str(GameManager.player.selected_monster.sp_def)
	$Panel/TrackerInfo/SPEED.text = str(GameManager.player.selected_monster.speed)
	$Panel/TrackerInfo/LUCK.text = str(GameManager.player.selected_monster.luck)
	$Panel/TrackerInfo/CRIT.text ="%2.0f" % (100.0 * GameManager.player.selected_monster.crit_chance) + "% " + "(%d)" % GameManager.player.selected_monster.crit_checks
	$Panel/TrackerInfo/ACC.text = str(GameManager.player.selected_monster.acc)
	_render_title_and_funds()


func populate_enemy_tracker():
	$Panel/TrackerInfo/TitlePlaceholder/Character_Name.text = GameManager.enemy.selected_monster.character_name
	_render_title_and_funds()


func _render_title_and_funds():
	if show_funds:
		%Character_Name.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		%Funds.text = "¶ %d" % GameManager.player.prana

	else:
		%Character_Name.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		%Funds.hide()
