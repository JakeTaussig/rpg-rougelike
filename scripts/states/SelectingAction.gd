extends BaseState

func enter(messages: Array = []):
	%PlayerPrompt.visible = true
	%Action.visible = true
	%ActionButtons.get_child(0).grab_focus()

	for button: Button in %ActionButtons.get_children():
		button.mouse_entered.connect(button.grab_focus)

	if messages.size() == 0:
		%PlayerPrompt.text = "What will %s do?" % %Player.selected_monster.character_name
	else:
		%PlayerPrompt.text = messages[0]

func exit():
	for button: Button in %ActionButtons.get_children():
		button.mouse_entered.disconnect(button.grab_focus)

	%PlayerPrompt.visible = false
	%Action.visible = false

func _on_attack_pressed() -> void:
	battle.transition_state_to(battle.STATE_SELECTING_ATTACK)

func _on_item_pressed() -> void:
	battle.transition_state_to(battle.STATE_SELECTING_ITEM)
