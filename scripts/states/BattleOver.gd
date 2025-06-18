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
