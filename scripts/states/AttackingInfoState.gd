class_name AttackingInfoState
extends BaseState

var messages: Array = []
var message_index: int = 0

@onready var BattleStatus: Label = %BattleStatus
@onready var ContinueButton: Button = %ContinueButton

@onready var StateDisplay: Label = %StateDisplay

func enter(_messages: Array = []):
	_render_hp()
	BattleStatus.visible = true
	ContinueButton.grab_focus()

	messages = _messages
	message_index = 0
	%BattleStatus.text = messages[message_index]
	print("\tmessage:\t\t%s" % messages[message_index])
	StateDisplay.text = "%s [%d / %d]" % [name, message_index+1, messages.size()]

func exit():
	BattleStatus.visible = false


func handle_continue():
	message_index += 1
	if message_index < messages.size():
		%BattleStatus.text = messages[message_index]
		print("\tmessage:\t\t%s" % messages[message_index])
		StateDisplay.text = "%s [%d / %d]" % [name, message_index+1, messages.size()]
	else:
		battle_system.transition_state_to("IncrementTurn")

func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)
