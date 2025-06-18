class_name UIManager
extends Node

# UI References
var backdrop: Sprite2D
var player_health_panel: RichTextLabel
var enemy_health_panel: RichTextLabel
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
	backdrop = %Backdrop
	player_health_panel = %PlayerHealthLabel
	enemy_health_panel = %EnemyHealthLabel
	state_display = %StateDisplay
	battle_status = %BattleStatus
	continue_button = %ContinueButton
	turn_display = %TurnDisplay
	action_menu = %Action
	moves_menu = %Moves
	items_menu = %Items
	player_prompt = %PlayerPrompt

	initialized = true


func set_backdrop_material(material: ShaderMaterial):
	backdrop.material = material


func clear_backdrop_material():
	backdrop.material = null


func render_hp(player_monster, enemy_monster):
	if !initialized:
		_init_references()

	if enemy_monster:
		enemy_health_panel.text = "%s" % enemy_monster.character_name
		%EnemyHPBar.max_value = enemy_monster.max_hp
		%EnemyHPBar.value = enemy_monster.hp
	else:
		enemy_health_panel.text = "Enemy ?"
	player_health_panel.text = "%s" % player_monster.character_name
	%PlayerHPBar.max_value = player_monster.max_hp
	%PlayerHPBar.value = player_monster.hp

	enemy_health_panel.text += ("\t%s" % set_bbcode_color(MovesList.Type.find_key(enemy_monster.type), MovesList.type_to_color(enemy_monster.type)))
	player_health_panel.text += ("\t%s" % set_bbcode_color(MovesList.Type.find_key(player_monster.type), MovesList.type_to_color(player_monster.type)))

	if not enemy_monster.status_effect == MovesList.StatusEffect.NONE:
		enemy_health_panel.text += (
			"\n\t\t\t\t\t  %s" % set_bbcode_color(type_abbreviation(enemy_monster.status_effect), MovesList.status_effect_to_color(enemy_monster.status_effect))
		)

	if not player_monster.status_effect == MovesList.StatusEffect.NONE:
		player_health_panel.text += (
			"\n\t\t\t\t\t  %s" % set_bbcode_color(type_abbreviation(player_monster.status_effect), MovesList.status_effect_to_color(player_monster.status_effect))
		)

	call_deferred("_adjust_player_health_panel_position")


func render_battlers():
	GameManager.player.render_battler()
	GameManager.enemy.render_battler()


func _adjust_player_health_panel_position():
	player_health_panel.adjust_position()


static func set_bbcode_color(input_string: String, color: Color):
	return "[color=%s]%s[/color]" % [color.to_html(), input_string]


func type_abbreviation(effect) -> String:
	match effect:
		MovesList.StatusEffect.CRIPPLE:
			return "CRP"
		MovesList.StatusEffect.BURN:
			return "BRN"
		MovesList.StatusEffect.WHIRLPOOL:
			return "WRL"
		MovesList.StatusEffect.POISON:
			return "PSN"
		MovesList.StatusEffect.PARALYZE:
			return "PAR"
		MovesList.StatusEffect.CONSUME:
			return "CSM"
		MovesList.StatusEffect.BLIND:
			return "BLD"
	printerr("Failed to match type abbreviation")
	return ""


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
