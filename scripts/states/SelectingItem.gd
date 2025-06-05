extends BaseState

var last_focused_item_index = 0

func enter(messages: Array = []):
	%Items.visible = true
	_render_items()
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
	# placeholder implementation
	for item in items:
		var menu_button = %ItemsMenu.get_child(0)
		menu_button.text = items[0].name
		menu_button.focus_entered.connect(func(): _display_qty_info(0))
		menu_button.mouse_entered.connect(menu_button.grab_focus)
		menu_button.pressed.connect(func(): _on_item_pressed(0))

		if items[0].qty <= 0:
			menu_button.set_theme_type_variation("DisabledButton")
		else:
			menu_button.set_theme_type_variation("Button")

# callback used when a item is focused
# displays the PP and type of the item in $"items/ItemsInfo"
func _display_qty_info(item_index: int) -> void:
	last_focused_item_index = item_index

	# HP restore
	if item_index == 0:
		%ItemQtyInfo.text = "Qty: %d / 99" % items[0].qty
		%ItemTypeInfo.text = items[0].description

func _on_item_pressed(item_index: int) -> void:
	var item = items[item_index]
	if item.qty > 0:
		item.callback.call()
		item.qty -= 1

var items: Array[Item] = []

func _ready():
	var hp_restore = Item.create("HP restore", 5, "Heals 30 HP", func():
		const HP_RESTORE_AMT = 30
		%Player.selected_monster.hp += HP_RESTORE_AMT
		battle.transition_state_to(battle.STATE_INFO, ["%s restored 30 HP" % %Player.selected_monster.character_name])
		)
	items = [
		hp_restore
	]

class Item:
	var name: String
	var qty: int
	var description: String
	var callback: Callable

	static func create(_name: String, _qty: int, _description: String, _callback: Callable):
		var output = Item.new()
		output.name = _name
		output.qty = _qty
		output.description = _description
		output.callback = _callback
		return output
