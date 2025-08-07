extends Control
class_name Tracker

func populate_player_tracker():
	$TrackerInfo/Character_Name.text = GameManager.player.selected_monster.character_name
	$TrackerInfo/HP.text = "%d/%d" % [GameManager.player.selected_monster.hp, GameManager.player.selected_monster.max_hp]
	$TrackerInfo/ATK.text = str(GameManager.player.selected_monster.atk)
	$TrackerInfo/SP_ATK.text = str(GameManager.player.selected_monster.sp_atk)
	$TrackerInfo/DEF.text = str(GameManager.player.selected_monster.def)
	$TrackerInfo/SP_DEF.text = str(GameManager.player.selected_monster.sp_def)
	$TrackerInfo/SPEED.text = str(GameManager.player.selected_monster.speed)
	$TrackerInfo/LUCK.text = str(GameManager.player.selected_monster.luck)
	$TrackerInfo/CRIT.text = str(GameManager.player.selected_monster.crit_chance)
	$TrackerInfo/ACC.text = str(GameManager.player.selected_monster.acc)
