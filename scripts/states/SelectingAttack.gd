extends BaseState
class_name SelectingAttack


func enter(_messages: Array = []):
	battle.ui_manager.show_moves_menu(true)
	battle.ui_manager.moves_menu.enter(_on_move_pressed)


func exit():
	battle.ui_manager.show_moves_menu(false)
	battle.ui_manager.moves_menu.exit()


func handle_input(event: InputEvent):
	# the "Back" button in the moves list emits the "ui_cancel" event when pressed
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)

func _on_move_pressed(index: int) -> void:
	var move = GameManager.player.selected_monster.moves[index]
	print("\tuser input:\t\tselect %s (idx %d)" % [move.move_name, index])
	if move.pp > 0:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = GameManager.player.selected_monster
		attackCommand.target = GameManager.enemy.selected_monster
		attackCommand.move = GameManager.player.selected_monster.moves[index]
		GameManager.current_battle.player_attack = attackCommand
		GameManager.current_battle.transition_state_to(GameManager.current_battle.STATE_INCREMENT_TURN)
