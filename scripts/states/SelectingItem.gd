extends BaseState

var last_focused_item_index = 0

func enter(messages: Array = []):
	%Items.visible = true
	%ItemsMenu.get_child(last_focused_item_index).grab_focus()
	_render_items()

func exit():
	%Items.visible = false
	for button: Button in %ItemsMenu.get_children():
		for dict in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", dict.callable)
		for dict in button.get_signal_connection_list("focus_entered"):
			button.disconnect("focus_entered", dict.callable)
		for dict in button.get_signal_connection_list("mouse_entered"):
			button.disconnect("mouse_entered", dict.callable)

func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)

func _render_items():
	# placeholder implementation
	%ItemsMenu.get_child(0).text = "HP Restore"
	%ItemsMenu.get_child(0).focus_entered.connect(func(): _display_qty_info(0))
	%ItemsMenu.get_child(0).mouse_entered.connect(%ItemsMenu.get_child(0).grab_focus)
	%ItemsMenu.get_child(0).pressed.connect(func(): _on_item_pressed(0))

	if %Player.backpack.hp_restore_qty <= 0:
		%MovesMenu.get_child(0).set_theme_type_variation("DisabledButton")
	else:
		%MovesMenu.get_child(0).set_theme_type_variation("Button")

# callback used when a item is focused
# displays the PP and type of the item in $"items/ItemsInfo"
func _display_qty_info(item_index: int) -> void:
	last_focused_item_index = item_index

	# HP restore
	if item_index == 0:
		%ItemQtyInfo.text = "Qty: %d / 99" % %Player.backpack.hp_restore_qty
		%ItemTypeInfo.text = "Heals 30 HP"

func _on_item_pressed(item_index: int) -> void:
	if item_index == 0:
		if %Player.backpack.consume_hp_restore(%Player.selected_monster):
			battle.transition_state_to(battle.STATE_INFO, ["%s restored 30 HP" % %Player.selected_monster.character_name])
