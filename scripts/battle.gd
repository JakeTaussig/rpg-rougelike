class_name Battle
extends Node2D

const STATE_INFO := "INFO"
const STATE_INCREMENT_TURN := "INCREMENT_TURN"
const STATE_SELECTING_ACTION := "SELECTING_ACTION"
const STATE_ENEMY_ATTACK := "ENEMY_ATTACK"
const STATE_BATTLE_OVER := "BATTLE_OVER"
const STATE_SELECTING_ATTACK := "SELECTING_ATTACK"
const STATE_ATTACK := "ATTACK"
const STATE_ENACT_STATUSES := "ENACT_STATUSES"
const NONE := "NONE"

var turn = 0
var turn_order_index := -1

# These are the attacks registered by the player and enemy for the given turn.
# These fields are overridden each turn.
var player_attack: AttackState.AttackCommand
var enemy_attack: AttackState.AttackCommand

var battle_participants = []
var player: BattleParticipant
var enemy: BattleParticipant

var active_monsters = []

var current_state: BaseState
var previous_state_name: String

var setup_done := false

# Connected in GameManager
signal battle_ended(victory: bool)

@onready var ui_manager: BattleUIManager = %BattleUiManager


func _ready() -> void:
	_init_states()
	_init_backdrop_image()
	call_deferred("_start_battle")

func _init_backdrop_image():
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


func setup(_player: BattleParticipant, _enemy: BattleParticipant):
	# assigns as reference
	player = _player
	enemy = _enemy
	update_active_monsters()
	setup_done = true
	print("Assigned player:", _player.name, _player.selected_monster.character_name)
	print("Assigned enemy:", enemy.name, enemy.selected_monster.character_name)

	player.selected_monster.trinkets_updated.connect(func():
		%TrinketShelf.render_trinkets()
		update_active_monsters()
	)


func update_active_monsters():
	active_monsters = [player.selected_monster, enemy.selected_monster]
	active_monsters.sort_custom(_sort_participants_by_speed)
	# Doing this removes the need to have is_player as a property on Monster
	if active_monsters[0] == player.selected_monster:
		battle_participants = [player, enemy]
	else:
		battle_participants = [enemy, player]
	if ui_manager:
		render_hp()


func _start_battle():
	render_hp()
	ui_manager.render_battlers()
	transition_state_to(STATE_INCREMENT_TURN)


func render_hp():
	ui_manager.render_hp(player.selected_monster, enemy.selected_monster)



func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			child.battle = self


# TODO: This may need to be called whenever a new monster enters the battle.
func _sort_participants_by_speed(a: Monster, b: Monster) -> bool:
	if a.speed == b.speed:
		return randf() < 0.5  # More readable than randi() % 2
	return a.speed > b.speed

func get_sorted_attacks():
	var turn_attacks: Array[AttackState.AttackCommand] = [player_attack, enemy_attack]

	if active_monsters[0] != GameManager.player.selected_monster:
		turn_attacks = [enemy_attack, player_attack]

	turn_attacks.sort_custom(_sort_attack_commands_by_monster_speed)
	turn_attacks.sort_custom(_sort_attack_commands_by_priority)

	return turn_attacks


func _sort_attack_commands_by_monster_speed(a: AttackState.AttackCommand, b: AttackState.AttackCommand) -> bool:
	return a.attacker.speed > b.attacker.speed


func _sort_attack_commands_by_priority(a: AttackState.AttackCommand, b: AttackState.AttackCommand) -> bool:
	if a.move.priority and not b.move.priority:
		return true
	elif b.move.priority and not a.move.priority:
		return false
	else:
		# if both moves, or no moves are priority, default to the existing
		# sorting (i.e. monster speed)
		return false

func transition_state_to(state_name: String, messages: Array = []):
	if not %BattleStateMachine.has_node(state_name):
		push_error("Invalid state: " + state_name)
		return

	if current_state:
		current_state.exit()
		previous_state_name = current_state.name

	print("Entering state: ", state_name)
	ui_manager.set_state_display(state_name)

	current_state = %BattleStateMachine.get_node(state_name)
	current_state.enter(messages)


func is_battle_over() -> bool:
	return enemy.is_defeated() || player.is_defeated()


func get_attacker():
	return active_monsters[turn_order_index]


func _on_continue_button_pressed() -> void:
	current_state.handle_continue()


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
