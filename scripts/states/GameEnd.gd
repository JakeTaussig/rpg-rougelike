extends InfoState

var player_victorious = true

func enter(_messages: Array = []):
	var player = %Player
	var enemy = %Enemy
	_messages = []
	if enemy.selected_monster.hp <= 0 and player.selected_monster.hp <= 0:
		_messages.append("%s and %s wiped each other out!" % [enemy.selected_monster.character_name, player.selected_monster.character_name])
		player_victorious = false
	elif enemy.selected_monster.hp <= 0:
		_messages.append("%s defeated %s!" % [player.selected_monster.character_name, enemy.selected_monster.character_name])
		_messages.append("Player won the battle!")
		player_victorious = true
	if player.selected_monster.hp <= 0:
		_messages.append("%s defeated %s!" % [enemy.selected_monster.character_name, player.selected_monster.character_name])
		player_victorious = false

	super.enter(_messages)

func handle_continue():
	if not player_victorious:
		get_tree().quit()
	else:
		# TODO: Need to remove current enemy and add new ones to the new battle?
		var battle_scene = preload("res://scenes/battle.tscn")
		var new_battle = battle_scene.instantiate()
		get_tree().current_scene.add_child(new_battle)
		battle.transition_state_to(battle.STATE_INCREMENT_TURN)
