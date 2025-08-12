class_name BattleUIManager
extends Node

# UI References
var backdrop: Sprite2D
var player_health_panel: HealthPanel
var enemy_health_panel: HealthPanel
var state_display: Label
var battle_status: Label
var continue_button: Button
var turn_display: Label
var action_menu: Control
var moves_menu: Control
var player_prompt: Label
# 0 = player, 1 = enemy
var last_active_tracker_index: bool = false

var initialized = false


func _ready():
	call_deferred("_init_references")


func _init_references():
	# Initialize references
	backdrop = %Backdrop
	enemy_health_panel = %EnemyHealthPanel
	player_health_panel = %PlayerHealthPanel
	state_display = %StateDisplay
	battle_status = %BattleStatus
	continue_button = %ContinueButton
	turn_display = %TurnDisplay
	action_menu = %Action
	moves_menu = %Moves
	player_prompt = %PlayerPrompt

	initialized = true


func set_backdrop_material(material: ShaderMaterial):
	backdrop.material = material


func reset_backdrop_material():
	if GameManager.floor_number == 2:
		backdrop.material = load("res://assets/shaders/water-material.tres")
		return

	backdrop.material = null

# TODO: move to battle UI manager
func init_backdrop_image():
	reset_backdrop_material()
	match GameManager.floor_number:
		1:
			%Backdrop.texture = load("res://assets/sprites/backdrops/earth_backdrop.png")
		2:
			%Backdrop.texture = load("res://assets/sprites/backdrops/water_backdrop.png")
		3:
			%Backdrop.texture = load("res://assets/sprites/backdrops/fire_backdrop.png")
		4:
			%Backdrop.texture = load("res://assets/sprites/backdrops/air_backdrop.png")
		5:
			%Backdrop.texture = load("res://assets/sprites/backdrops/ether_backdrop.png")
		6:
			%Backdrop.texture = load("res://assets/sprites/backdrops/light_backdrop.png")
		7:
			%Backdrop.texture = load("res://assets/sprites/backdrops/cosmic_backdrop.png")
		_:
			%Backdrop.texture = load("res://assets/sprites/backdrops/earth_backdrop.png")


func render_hp(player_monster, enemy_monster):
	if !initialized:
		_init_references()

	await enemy_health_panel.render_hp(enemy_monster)
	await player_health_panel.render_hp(player_monster)


func render_battlers():
	GameManager.player.render_battler()
	GameManager.enemy.render_battler()


func show_info_panel(visible: bool):
	battle_status.visible = visible
	continue_button.visible = visible


func set_info_text(text: String):
	battle_status.text = text


func focus_continue_button():
	continue_button.grab_focus()

func disable_continue_button():
	continue_button.disabled = true

func enable_continue_button():
	continue_button.disabled = false

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


func get_move_buttons() -> Array[Node]:
	return moves_menu.get_node("MovesMenu").get_children()


func get_action_buttons() -> Array[Node]:
	return %ActionButtons.get_children()


func set_button_style_enabled(button: Button, enabled: bool):
	if enabled:
		button.set_theme_type_variation("DisabledButton")
	else:
		button.set_theme_type_variation("Button")
		

func display_tracker():
	if last_active_tracker_index == false:
		GameManager.current_battle.player.selected_monster.tracker.visible = true
		GameManager.current_battle.enemy.selected_monster.tracker.visible = false
	elif last_active_tracker_index == true:
		GameManager.current_battle.enemy.selected_monster.tracker.visible = true
		GameManager.current_battle.player.selected_monster.tracker.visible = false
		
		
func hide_health_panels_for_trackers():
	if GameManager.player.selected_monster.tracker.visible:
		player_health_panel.hide()
		enemy_health_panel.show()
	if GameManager.enemy.selected_monster.tracker.visible:
		enemy_health_panel.hide()
		player_health_panel.show()


func set_pp_info(text: String, disabled: bool):
	var pp_display = moves_menu.get_node("MoveInfo/InfoContainer/PPInfo")
	var pp_label = moves_menu.get_node("MoveInfo/InfoContainer/PPInfoLabel")
	pp_display.text = text
	if disabled:
		pp_display.set_theme_type_variation("SmallTextRedTextLabel")
		pp_label.set_theme_type_variation("SmallTextRedTextLabel")

	else:
		pp_display.set_theme_type_variation("TinyTextLabel")
		pp_label.set_theme_type_variation("TinyTextLabel")


func set_type_info(type: MovesList.Type, disabled: bool):
	var type_info = moves_menu.get_node("MoveInfo/InfoContainer/TypeInfo")
	var type_label = moves_menu.get_node("MoveInfo/InfoContainer/TypeInfoLabel")

	var text = MovesList.Type.keys()[type]
	type_info.text = text

	if disabled:
		type_info.set_theme_type_variation("SmallTextDisabledLabel")
		type_label.set_theme_type_variation("SmallTextDisabledLabel")
		type_info.remove_theme_color_override("font_color")
	else:
		type_info.set_theme_type_variation("TinyTextLabel")
		type_label.set_theme_type_variation("TinyTextLabel")

		var type_color = MovesList.type_to_color(type)
		type_info.add_theme_color_override("font_color", type_color)

func set_move_power(power: int, disabled: bool):
	var power_display = moves_menu.get_node("MoveInfo/InfoContainer/Power")
	var power_label = moves_menu.get_node("MoveInfo/InfoContainer/PowerLabel")
	power_display.text = "%d" % power
	if disabled:
		power_display.set_theme_type_variation("SmallTextDisabledLabel")
		power_label.set_theme_type_variation("SmallTextDisabledLabel")
	else:
		power_display.set_theme_type_variation("TinyTextLabel")
		power_label.set_theme_type_variation("TinyTextLabel")

func set_move_accuracy(acc: int, disabled: bool):
	var acc_display = moves_menu.get_node("MoveInfo/InfoContainer/Acc")
	var acc_label = moves_menu.get_node("MoveInfo/InfoContainer/AccLabel")
	acc_display.text = "%d" % acc
	if disabled:
		acc_display.set_theme_type_variation("SmallTextDisabledLabel")
		acc_label.set_theme_type_variation("SmallTextDisabledLabel")
	else:
		acc_display.set_theme_type_variation("TinyTextLabel")
		acc_label.set_theme_type_variation("TinyTextLabel")
