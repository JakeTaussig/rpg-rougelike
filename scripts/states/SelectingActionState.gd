extends BaseState

func enter(messages: Array = []):
	%PlayerPrompt.visible = true
	if messages.size() == 0:
		%PlayerPrompt.text = "What will %s do?" % %Player.character_name
	else:
		%PlayerPrompt.text = messages[0]
	%Action.visible = true
	%Action.get_child(0).grab_focus()

func exit():
	%PlayerPrompt.visible = false
	%Action.visible = false

func _on_attack_pressed() -> void:
	battle.transition_state_to(battle.BattleState.SELECTING_ATTACK)
