class_name Battle
extends Node2D
var turn: int = 0
var turn_order_index: int = -1

var battle_participants = []
var enemy: BattleParticipant

var states: Dictionary = {}
var current_state: BaseState

enum BattleState {
	ATTACKING_INFO,
	INCREMENT_TURN,
	SELECTING_ACTION,
	ENEMY_ATTACK,
	GAME_END,
	SELECTING_ATTACK
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()

	transition_state_to(BattleState.ATTACKING_INFO, [""]) # Start in AttackingInfo to render HP
	transition_state_to(BattleState.INCREMENT_TURN)

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			states[child.name] = child
			child.battle = self

func _init_battle_participants():
	battle_participants.clear()
	battle_participants.append(%Player)
	for enemy_node in %Enemies.get_children():
		enemy_node.is_player = false
		battle_participants.append(enemy_node)
		enemy = enemy_node
		
	
	battle_participants.sort_custom(_sort_participants_by_speed)
	
func _sort_participants_by_speed(a, b) -> bool:
	if a.speed == b.speed:
		return randf() < 0.5  # More readable than randi() % 2
	return a.speed > b.speed

func transition_state_to(state: BattleState, messages: Array = []):
	var state_name = BattleState.keys()[state]
	if not states.has(state_name):
		push_error("Invalid state: " + state_name)
		return
		
	if current_state:
		current_state.exit()

	print("entering state: ", state_name)
	%StateDisplay.text = state_name

	current_state = states[state_name]
	current_state.enter(messages)

func attack(index: int, target: BattleParticipant) -> void:
	var attacker: BattleParticipant = battle_participants[turn_order_index]
	var results = attacker.use_move(index, target)
	var used_move = attacker.moves[index]
	var messages = _generate_attack_messages(attacker, target, used_move, results)
	transition_state_to(BattleState.ATTACKING_INFO, messages)

func _generate_attack_messages(attacker, target, used_move, results) -> Array:
	var messages = []
	var used_move_name = results["move"].move_name
	var damage = results["damage"]
	var move_hit = results["move_hit"]
	if not move_hit:
		messages.append("%s missed %s!" % [attacker.character_name, used_move_name])
	elif damage > 0:
		var effectiveness_multiplier: float = attacker.get_effectiveness_modifier(used_move, target)
		messages.append("%s used %s on %s for %d damage!" % [attacker.character_name, used_move_name, target.character_name, damage])
	
		if effectiveness_multiplier > 1.0:
			messages.append("%s was super effective!" % used_move_name)
	
		elif effectiveness_multiplier < 1.0:
			messages.append("%s was not very effective!" % used_move_name)
	
	# This should only be status effects for now
	else:
		var status_effect_string = String(MovesList.StatusEffect.find_key(target.status_effect)).to_lower()
		messages.append("%s used %s and applied %s on %s!" % [attacker.character_name, used_move_name, status_effect_string, target.character_name])
	return messages

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

func get_current_attacker():
	return battle_participants[turn_order_index]
