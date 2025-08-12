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
		

func set_tracker_info(monster: Monster):
	var tracker = GameManager.tracker
	tracker.get_child(0).text = "%d/%d" % [monster.max_hp, monster.hp]