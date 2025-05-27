extends BaseState

@onready var PlayerPrompt: Label = %PlayerPrompt
@onready var Action: VBoxContainer = %Action

func enter(messages: Array = []):
	PlayerPrompt.visible = true
	if messages.size() == 0:
		PlayerPrompt.text = "What will %s do?" % %Player.character_name
	else:
		PlayerPrompt.text = messages[0]
	Action.visible = true
	Action.get_child(0).grab_focus()

func exit():
	PlayerPrompt.visible = false
	Action.visible = false

func _on_attack_pressed() -> void:
	battle_system.transition_state_to("SelectingAttack")
