class_name UIManager
extends Node

# UI References
var player_panel: Label
var enemy_panel: Label
var state_display: Label
var battle_status: Label
var continue_button: Button
var turn_display: Label
var action_menu: Control
var moves_menu: Control
var items_menu: Control
var player_prompt: Label

var initialized = false

func _ready():
	call_deferred("_init_references")

func _init_references():
	# Initialize references
	player_panel = %PlayerPanel
	enemy_panel = %EnemyPanel
	state_display = %StateDisplay
	battle_status = %BattleStatus
	continue_button = %ContinueButton
	turn_display = %TurnDisplay
	action_menu = %Action
	moves_menu = %Moves
	items_menu = %Items
	player_prompt = %PlayerPrompt

	initialized = true

func render_hp(player_monster, enemy_monster):
	if !initialized:
		_init_references()

	if enemy_monster:
		enemy_panel.text = "%s %d / %d" % [enemy_monster.character_name, enemy_monster.hp, enemy_monster.max_hp]
	else:
		enemy_panel.text = "Enemy ?"
	player_panel.text = "%s %d / %d" % [player_monster.character_name, player_monster.hp, player_monster.max_hp]

	enemy_panel.text += "\n%s" % MovesList.Type.find_key(enemy_monster.type)
	player_panel.text += "\n%s" % MovesList.Type.find_key(player_monster.type)

	if not enemy_monster.status_effect == MovesList.StatusEffect.NONE:
		enemy_panel.text += "\t \t \t \t %s" % MovesList.StatusEffect.find_key(enemy_monster.status_effect)

	if not player_monster.status_effect == MovesList.StatusEffect.NONE:
		player_panel.text += "\t \t \t \t  %s" % MovesList.StatusEffect.find_key(player_monster.status_effect)

func show_info_panel(visible: bool):
	battle_status.visible = visible
	continue_button.visible = visible

func set_info_text(text: String):
	battle_status.text = text

func focus_continue_button():
	continue_button.grab_focus()

func focus_action_button():
	%ActionButtons.get_child(0).grab_focus()

func set_state_display(text: String):
	if state_display:
		state_display.text = text

func set_turn_display(text: String):
	turn_display.text = text

func show_action_menu(visible: bool):
	action_menu.visible = visible

func set_player_prompt(text: String):
	player_prompt.text = text

func show_player_prompt(visible: bool):
	player_prompt.visible = visible

func show_moves_menu(visible: bool):
	moves_menu.visible = visible

func show_items_menu(visible: bool):
	items_menu.visible = visible

func focus_items_back_button():
	%Items.get_node("BackButton").grab_focus()

func get_move_buttons() -> Array[Node]:
	return moves_menu.get_node("MovesMenu").get_children()

func get_item_buttons() -> Array[Node]:
	return %ItemsMenu.get_children()

func add_item_button(button: Button):
	%ItemsMenu.add_child(button)

func get_action_buttons() -> Array[Node]:
	return %ActionButtons.get_children()

func set_button_style_enabled(button: Button, enabled: bool):
	if enabled:
		button.set_theme_type_variation("DisabledButton")
	else:
		button.set_theme_type_variation("Button")

func set_pp_info(text: String, disabled: bool):
	moves_menu.get_node("MoveInfo/PPInfo").text = text
	if disabled:
		moves_menu.get_node("MoveInfo/PPInfo").set_theme_type_variation("RedTextLabel")
	else:
		moves_menu.get_node("MoveInfo/PPInfo").set_theme_type_variation("NoBorderLabel")

func set_type_info(text: String, disabled: bool):
	moves_menu.get_node("MoveInfo/TypeInfo").text = text
	if disabled:
		moves_menu.get_node("MoveInfo/TypeInfo").set_theme_type_variation("RedTextLabel")
	else:
		moves_menu.get_node("MoveInfo/TypeInfo").set_theme_type_variation("NoBorderLabel")

func set_item_qty_info(text: String):
	items_menu.get_node("ItemInfo/ItemQtyInfo").text = text

func set_item_type_info(text: String):
	items_menu.get_node("ItemInfo/ItemTypeInfo").text = text
