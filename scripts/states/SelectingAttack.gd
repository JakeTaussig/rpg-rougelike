extends BaseState
class_name SelectingAttack


func enter(_messages: Array = []):
	battle.ui_manager.show_moves_menu(true)
	battle.ui_manager.moves_menu.enter()


func exit():
	battle.ui_manager.show_moves_menu(false)
	battle.ui_manager.moves_menu.exit()


func handle_input(event: InputEvent):
	# the "Back" button in the moves list emits the "ui_cancel" event when pressed
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)
