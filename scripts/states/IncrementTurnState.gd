extends BaseState

var _initialized = false

func enter(_messages: Array = []):
	if check_battle_end():
		battle_system.transition_state_to("GameEnd")
		return

	battle_system.turn_order_index += 1
	if battle_system.turn_order_index == battle_system.battle_participants.size():
		battle_system.turn_order_index = 0
		battle_system.turn += 1
		_log_turn_info()

	# print the turn number for the first turn
	if !_initialized:
		_initialized = true
		_log_turn_info()

	%TurnDisplay.text = "trn: %s idx: %s" % [battle_system.turn, battle_system.turn_order_index]

	if battle_system.battle_participants[battle_system.turn_order_index].is_player:
		battle_system.transition_state_to("SelectingAction")
	else:
		battle_system.transition_state_to("EnemyAttack")

func check_battle_end():
	if battle_system.enemy.hp <= 0:
		return true
	if %Player.hp <= 0:
		return true
	return false

func _log_turn_info():
	print("---------------------------")
	print("Turn: %d" % (battle_system.turn + 1))
	print("---------------------------")
