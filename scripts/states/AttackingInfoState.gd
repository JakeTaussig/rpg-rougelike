class_name AttackingInfoState
extends BaseState

var messages: Array = []
var message_index: int = 0

func enter(_messages: Array = []):
	_render_hp()
	%BattleStatus.visible = true
	%ContinueButton.grab_focus()

	messages = _messages
	message_index = 0
	%BattleStatus.text = messages[message_index]
	print("\tmessage:\t\t%s" % messages[message_index])
	_update_state_display()

func exit():
	%BattleStatus.visible = false


func handle_continue():
	message_index += 1
	if message_index < messages.size():
		%BattleStatus.text = messages[message_index]
		print("\tmessage:\t\t%s" % messages[message_index])
		_update_state_display()
	else:
		battle.transition_state_to(battle.BattleState.INCREMENT_TURN)

func _update_state_display():
	var attacker_string = "E"
	if battle.get_current_attacker() == %Player:
		return "P"

	%StateDisplay.text = "%s [%s] [%d / %d]" % [name, attacker_string, message_index+1, messages.size()]


func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)
