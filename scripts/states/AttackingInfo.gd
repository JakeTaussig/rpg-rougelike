class_name AttackingInfoState
extends BaseState

var messages: Array = []
var message_index: int = 0

func enter(_messages: Array = []):
	battle.render_hp()
	%BattleStatus.visible = true
	%ContinueButton.visible = true
	%ContinueButton.grab_focus()
	messages = _messages
	message_index = 0
	_update_message()

func exit():
	%BattleStatus.visible = false
	%ContinueButton.visible = false

func handle_continue():
	message_index += 1
	if message_index < messages.size():
		_update_message()
	else:
		battle.transition_state_to(battle.STATE_ENACT_STATUSES, battle.STATE_INFO)
	# If last state == ENACT_STATUSES, transition to INCREMENT_TURN

func _update_message():
	%BattleStatus.text = messages[message_index]
	print("\tmessage:\t\t%s" % messages[message_index])
	_update_state_display()

func _update_state_display():
	%StateDisplay.text = "%s [%d / %d]" % [name, message_index+1, messages.size()]
