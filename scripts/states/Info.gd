class_name InfoState
extends BaseState

var messages: Array = []
var message_index: int = 0

func enter(_messages: Array = []):
	battle.ui_manager.render_hp(GameManager.player.selected_monster, GameManager.enemy.selected_monster)
	battle.ui_manager.render_battlers()
	battle.ui_manager.show_info_panel(true)
	battle.ui_manager.focus_continue_button()
	messages = _messages
	message_index = 0
	_update_message()
	if messages.size() == 0:
		print("\tno messages; skipping INFO state")
		handle_continue()

func exit():
	battle.ui_manager.clear_backdrop_material()
	battle.ui_manager.show_info_panel(false)

func handle_continue():
	message_index += 1
	if message_index < messages.size():
		_update_message()
	else:
		battle.transition_state_to(battle.STATE_INCREMENT_TURN)

func _update_message():
	if messages.size() >= 1:
		battle.ui_manager.set_info_text(messages[message_index])
		print("\tmessage:\t\t%s" % messages[message_index])
		_update_state_display()

func _update_state_display():
	battle.ui_manager.set_state_display("%s [%d / %d]" % [name, message_index+1, messages.size()])
