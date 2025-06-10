extends BaseState

var last_focused_item_index = 0

func enter(_messages: Array = []):
	%Items.visible = true
	_render_items()
	call_deferred("_refocus")
	if _messages.size() != 0 && _messages[0] == "replenish":
		%Player.items[last_focused_item_index].qty += 1

func _refocus():
	var child_count = %ItemsMenu.get_child_count()
	if last_focused_item_index >= child_count:
		last_focused_item_index = child_count - 1

	if last_focused_item_index <= -1:
		%Items.get_node("BackButton").grab_focus()
		return

	%ItemsMenu.get_child(last_focused_item_index).grab_focus()

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
	# Clear existing items first (except the first one which has focus signals)
	var child_count = %ItemsMenu.get_child_count()
	while child_count > 0:
		var second_child = %ItemsMenu.get_child(0)
		second_child.free()
		child_count = %ItemsMenu.get_child_count()

	var visible_item_index = 0
	for i in %Player.items.size():
		if %Player.items[i].qty <= 0:
			continue  # Skip items with qty <= 0

		var menu_button
		if visible_item_index < %ItemsMenu.get_child_count():
			menu_button = %ItemsMenu.get_child(visible_item_index)
		else:
			# duplicate the second menu button, because the first has focus signals connected to the back button
			menu_button = %ItemsMenu.get_child(0).duplicate()
			%ItemsMenu.add_child(menu_button)

		menu_button.text = %Player.items[i].name
		menu_button.focus_entered.connect(func(): _display_qty_info(i))
		menu_button.mouse_entered.connect(menu_button.grab_focus)
		menu_button.pressed.connect(func(): _on_item_pressed(i))
		menu_button.set_theme_type_variation("Button")

		visible_item_index += 1
# callback used when a item is focused
# displays the PP and type of the item in $"items/ItemsInfo"
func _display_qty_info(item_index: int) -> void:
	last_focused_item_index = item_index

	%ItemQtyInfo.text = "%d / 99" % %Player.items[item_index].qty
	%ItemTypeInfo.text = %Player.items[item_index].description

func _on_item_pressed(item_index: int) -> void:
	var item = %Player.items[item_index]
	item.consume(%Player.selected_monster, battle)
