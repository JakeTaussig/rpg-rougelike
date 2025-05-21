extends Node2D
class_name BattleParticipant

@export var character_name: String = "Player"
@export var max_hp: int = 100:
	set(new_health):
		max_hp = max(1, new_health)
@export var hp: int = 100:
	set(new_health):
		hp = max(0, new_health)
@export var atk: int = 20:
	set(new_atk):
		atk = max(1, new_atk)
@export var sp_atk: int = 20:
	set(new_sp_atk):
		sp_atk = max(1, new_sp_atk)
@export var def: int = 20:
	set(new_def):
		def = max(1, new_def)
@export var sp_def: int = 20:
	set(new_sp_def):
		sp_def = max(1, new_sp_def)
@export var speed: int = 30:
	set(new_speed):
		speed = max(1, new_speed)
@export var luck: int = 10:
	set(new_luck):
		luck = max(1, new_luck)
@export var type: MovesData.Type = MovesData.Type.HUMAN
var is_player = true
var moves: Array[Move] = []
var status_effect = MovesData.StatusEffect.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _init():
	# DEBUG: for now each battle participant's moves are set to copy the global moves_list
	for move in GameManager.moves_list:
		moves.append(move.copy())

func use_move(index: int, target: BattleParticipant) -> Dictionary:
	var move = moves[index]
	move.pp -= 1
	var move_hit: bool = _does_move_hit(move.acc)
	var damage = 0
	if move_hit:
		if move.category == Move.MoveCategory.ATK:
			damage = max(1, _attack(move, target, 1))
		elif move.category == Move.MoveCategory.SP_ATK:
			damage = max(1, _attack(move, target, 0))
		if move.status_effect != MovesData.StatusEffect.NONE:
			_roll_and_apply_status_effect(move, target)
	return {"move": move, "damage": damage, "move_hit": move_hit}

func _does_move_hit(accuracy: int) -> bool:
	accuracy = clamp(accuracy, 0, 100)
	
	# Generates a number between 1 and 100
	var roll = randi() % 100 + 1
	return roll <= accuracy
	
func increment_health(value: int) -> void:
	hp += value
	
func _attack(move: Move, target: BattleParticipant, is_physical: bool) -> int:
	var power = move.base_power
	var damage = 0
	var effectiveness_modifier = get_move_effectiveness(move, target)
	if is_physical:
		power = power * atk
		damage = power / target.def
		damage *= effectiveness_modifier
	else:
		power = power * sp_atk
		damage = power / target.sp_def
		damage *= effectiveness_modifier
	target.hp -= damage
	return damage
	
func _roll_and_apply_status_effect(move: Move, target: BattleParticipant):
	# Only attempt to apply a status effect if one is not already applied
	if target.status_effect == MovesData.StatusEffect.NONE:
		var status_applied = _does_move_hit(move.status_effect_chance)
		if status_applied:
			target.status_effect = move.status_effect
		
func get_move_effectiveness(move: Move,  defender: BattleParticipant) -> float:
	var same_type_attack_bonus: float = 1.5 if self.type == move.type else 1.0
	var base_modifier = get_effectiveness_modifier(move, defender)
	return base_modifier * same_type_attack_bonus
	
func get_effectiveness_modifier(move: Move, defender: BattleParticipant) -> float:
	var atk_idx = MovesData.TYPES[move.type]
	var def_idx = MovesData.TYPES[defender.type]
	var base_modifier = MovesData.TYPE_CHART[atk_idx][def_idx]
	return base_modifier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
