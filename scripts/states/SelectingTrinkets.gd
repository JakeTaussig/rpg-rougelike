extends BaseState
class_name SelectingTrinkets

var last_focused_item_index = 0


func enter(_messages: Array = []):
	%Trinkets.visible = true
	_render_trinkets()
	%TrinketsMenu.get_child(0).grab_focus()
	

	
func exit():
	%Trinkets.visible = false

func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)


func _render_trinkets():
	while %TrinketsMenu.get_children().size() > 1:
		%TrinketsMenu.get_children()[1].free()
	
	for i in GameManager.player.trinkets.size():
		var trinket_button = %TrinketsMenu.get_children()[0]
		if i != 0:
			trinket_button = trinket_button.duplicate()
			trinket_button.focus_neighbor_top = NodePath("")
			%TrinketsMenu.add_child(trinket_button)

		trinket_button.text = GameManager.player.trinkets[i].trinket_name
		trinket_button.focus_entered.connect(func(): _render_trinket_description(i))
		trinket_button.mouse_entered.connect(trinket_button.grab_focus)
		trinket_button.set_theme_type_variation("Trinket_Button")

func _render_trinket_description(item_index: int):
	last_focused_item_index = item_index

	%TrinketInfoLabel.text = "%s" % GameManager.player.trinkets[item_index].description
	
