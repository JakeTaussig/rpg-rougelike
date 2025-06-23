extends InfoState

var _player_victorious = true
var _has_finished = false


func enter(_messages: Array = []):
	var player = GameManager.player
	var enemy = GameManager.enemy
	_messages = []
	if enemy.selected_monster.hp <= 0 and player.selected_monster.hp <= 0:
		_player_victorious = false
		_messages.append("You lost the Battle. Proceeding...")
	elif enemy.selected_monster.hp <= 0:
		if GameManager.floor_events.is_empty():
			#player.remove_trinkets()
			GameManager.level_up_player_and_enemies()
			match GameManager.floor_number:
				1:
					_messages.append("You cleared the 1st circle of hell!")
				2:
					_messages.append("You cleared the 2nd circle of hell!")
				3:
					_messages.append("You cleared the 3rd circle of hell!")
				_:
					messages.append("You cleared the %dth circle of hell!" % GameManager.floor_number)
			_messages.append(
				(
					"%s's struggle made their spirit stronger! All of their stats were increased by %.1fx!"
					% [player.selected_monster.character_name, GameManager.player_stat_multiplier]
				)
			)
			_messages.append("The enemies grow stronger as you descend deeper into hell!")
		else:
			_messages.append("You won the Battle! Proceeding...")
		_player_victorious = true
	elif player.selected_monster.hp <= 0:
		_messages.append("You lost the Battle. Proceeding...")
		_player_victorious = false

	if _player_victorious:
		if player.selected_monster.status_effect != MovesList.StatusEffect.NONE:
			var message = player.selected_monster.recover_from_status_effect()
			_messages.push_front(message)

	super.enter(_messages)


func handle_continue():
	message_index += 1
	if message_index < messages.size():
		_update_message()
		return

	# Guard against duplicate transition
	if _has_finished:
		return
	_has_finished = true

	if not _player_victorious:
		get_tree().quit()
	else:
		# Let the old battle scene finish it's state logic first
		call_deferred("_end_battle")


func _end_battle():
	battle.emit_signal("battle_ended", _player_victorious)
