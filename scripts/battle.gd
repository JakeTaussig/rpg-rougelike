class_name Battle
extends Node2D

const STATE_INFO := "INFO"
const STATE_INCREMENT_TURN := "INCREMENT_TURN"
const STATE_SELECTING_ACTION := "SELECTING_ACTION"
const STATE_ENEMY_ATTACK := "ENEMY_ATTACK"
const STATE_GAME_END := "GAME_END"
const STATE_SELECTING_ATTACK := "SELECTING_ATTACK"
const STATE_SELECTING_ATTACK_PP_RESTORE := "SELECTING_ATTACK_PP_RESTORE"
const STATE_ATTACK := "ATTACK"
const STATE_ENACT_STATUSES := "ENACT_STATUSES"
const STATE_SELECTING_ITEM := "SELECTING_ITEM"
const NONE := "NONE"

var turn: int = 0
var turn_order_index: int = -1

var battle_participants = []

var active_monsters = []
var current_enemy: Monster

var current_state: BaseState
var previous_state_name: String

@onready var ui_manager: UIManager = %UiManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			child.battle = self

func _init_battle_participants():
	active_monsters.clear()
	active_monsters.append(%Player.selected_monster)
	battle_participants.append(%Player)
	battle_participants.append(%Enemy)
	current_enemy = %Enemy.monsters[0]
	active_monsters.append(current_enemy)
	active_monsters.sort_custom(_sort_participants_by_speed)
	ui_manager.render_hp(%Player.selected_monster, current_enemy)
	transition_state_to(STATE_INCREMENT_TURN)

func _sort_participants_by_speed(a: Monster, b: Monster) -> bool:
	if a.speed == b.speed:
		return randf() < 0.5  # More readable than randi() % 2
	return a.speed > b.speed

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
	return (%Enemy.selected_monster.hp <= 0 && %Enemy.monsters.size() == 1) || (%Player.selected_monster.hp <= 0 && %Player.monsters.size() == 1)

func get_attacker():
	return active_monsters[turn_order_index]

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

func _input(event: InputEvent) -> void:
	current_state.handle_input(event)
