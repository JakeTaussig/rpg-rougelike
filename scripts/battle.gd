class_name Battle
extends Node2D
var turn: int = 0
var turn_order_index: int = -1

var battle_participants = []
var enemy: BattleParticipant

var states: Dictionary = {}
var current_state: BaseState

@onready var StateDisplay: Label = %StateDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()

	transition_state_to("AttackingInfo", [""]) # Start in AttackingInfo to render HP
	transition_state_to("IncrementTurn")

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			states[child.name] = child
			child.battle_system = $"."

func _init_battle_participants():
	for enemy in %Enemies.get_children():
		enemy.is_player = false
		battle_participants.append(enemy)
		battle_participants.append(%Player)
	battle_participants.sort_custom(func(a, b):
		if a.speed == b.speed:
			return randi() % 2 == 0
		return a.speed > b.speed)

	enemy = %Enemies.get_child(0)

func transition_state_to(state_name: String, messages: Array = []):
	if current_state:
		current_state.exit()

	print("entering state: ", state_name)
	StateDisplay.text = state_name

	current_state = states[state_name]
	current_state.enter(messages)

func attack(index: int, target: BattleParticipant) -> void:
	var _messages = []
	var attacker: BattleParticipant = battle_participants[turn_order_index]
	var results = attacker.use_move(index, target)
	var used_move_name = results["move"].move_name
	var damage = results["damage"]
	var move_hit = results["move_hit"]
	if not move_hit:
		_messages.append("%s missed %s!" % [attacker.character_name, used_move_name])
	elif damage > 0:
		var effectiveness_multiplier: float = attacker.get_effectiveness_modifier(attacker.moves[index], target)
		_messages.append("%s used %s on %s for %d damage!" % [attacker.character_name, used_move_name, target.character_name, damage])

		if effectiveness_multiplier > 1.0:
			_messages.append("%s was super effective!" % used_move_name)

		elif effectiveness_multiplier < 1.0:
			_messages.append("%s was not very effective!" % used_move_name)

	# This should only be status effects for now
	else:
		var status_effect_string = String(MovesList.StatusEffect.find_key(target.status_effect)).to_lower()
		_messages.append("%s used %s and applied %s on %s!" % [attacker.character_name, used_move_name, status_effect_string, target.character_name])

	transition_state_to("AttackingInfo", _messages)

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

func get_current_attacker():
	return battle_participants[turn_order_index]
