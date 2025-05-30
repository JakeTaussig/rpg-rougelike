extends BaseState

func enter(messages: Array = []):
	%PlayerPrompt.visible = true
	%Action.visible = true
	%Action.get_child(0).grab_focus()

	if messages.size() == 0:
		%PlayerPrompt.text = "What will %s do?" % %Player.monster.character_name
	else:
		%PlayerPrompt.text = messages[0]

func exit():
	%PlayerPrompt.visible = false
	%Action.visible = false

func _on_attack_pressed() -> void:
	battle.transition_state_to(battle.STATE_SELECTING_ATTACK)
