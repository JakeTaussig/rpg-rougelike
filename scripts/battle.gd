class_name Battle
extends Node2D

const STATE_INFO := "INFO"
const STATE_INCREMENT_TURN := "INCREMENT_TURN"
const STATE_SELECTING_ACTION := "SELECTING_ACTION"
const STATE_ENEMY_ATTACK := "ENEMY_ATTACK"
const STATE_BATTLE_OVER := "BATTLE_OVER"
const STATE_SELECTING_ATTACK := "SELECTING_ATTACK"
const STATE_SELECTING_ATTACK_PP_RESTORE := "SELECTING_ATTACK_PP_RESTORE"
const STATE_ATTACK := "ATTACK"
const STATE_ENACT_STATUSES := "ENACT_STATUSES"
const STATE_SELECTING_ITEM := "SELECTING_ITEM"
const NONE := "NONE"

var turn = 0
var turn_order_index := -1

var battle_participants = []
var player: BattleParticipant
var enemy: BattleParticipant

var active_monsters = []

var current_state: BaseState
var previous_state_name: String

var setup_done := false

signal battle_ended(victory: bool)

@onready var ui_manager: UIManager = %UiManager


func _ready() -> void:
	_init_states()
	call_deferred("_start_battle")


func setup(_player: BattleParticipant, _enemy: BattleParticipant):
	# assigns as reference
	player = _player
	enemy = _enemy
	battle_participants = [player, enemy]
	active_monsters = [player.selected_monster, enemy.selected_monster]
	active_monsters.sort_custom(_sort_participants_by_speed)
	setup_done = true
	print("Assigned player:", _player.name, _player.selected_monster.character_name)
	print("Assigned enemy:", enemy.name, enemy.selected_monster.character_name)


func _start_battle():
	ui_manager.render_hp(player.selected_monster, enemy.selected_monster)
	ui_manager.render_battlers()
	transition_state_to(STATE_INCREMENT_TURN)


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
	return (enemy.selected_monster.hp <= 0 && enemy.monsters.size() == 1) || (player.selected_monster.hp <= 0 && player.monsters.size() == 1)


func get_attacker():
	return active_monsters[turn_order_index]


func _on_continue_button_pressed() -> void:
	current_state.handle_continue()


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
