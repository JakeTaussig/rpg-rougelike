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
@export var type: MovesData.Type = MovesData.Type.Human
var is_player = true
var moves: Array[Move] = []
enum effectiveness { NORMAL, SUPER_EFFECTIVE, NOT_VERY_EFFECTIVE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _init():
	# DEBUG: for now each battle participant's moves are set to copy the global moves_list
	for move in GameManager.moves_list:
		moves.append(move.copy())

func use_move(index: int, target: BattleParticipant) -> Array:
	var move = moves[index]
	move.pp -= 1
	var attack_hit: bool = _does_attack_hit(move.acc)
	if attack_hit:
		var damage = 0
		if move.category == Move.MoveCategory.ATK:
			damage = max(1, _attack(move, target, 1))
			return [move, damage]
		elif move.category == Move.MoveCategory.SP_ATK:
			damage = max(1, _attack(move, target, 0))
			return [move, damage]
	return [move, 0]

func _does_attack_hit(accuracy: int):
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
	
func get_move_effectiveness(move: Move,  defender: BattleParticipant) -> float:
	var same_type_attack_bonus: float = 1.5 if self.type == move.type else 1.0
	var base_modifier = get_effectiveness_modifier(move, defender)
	var move_effectiveness = effectiveness.NORMAL if base_modifier == 1.0 else effectiveness.SUPER_EFFECTIVE if base_modifier > 1.0 else effectiveness.NOT_VERY_EFFECTIVE
	return base_modifier * same_type_attack_bonus
	
func get_effectiveness_modifier(move: Move, defender: BattleParticipant) -> float:
	var atk_idx = MovesData.TYPES[move.type]
	var def_idx = MovesData.TYPES[defender.type]
	var base_modifier = MovesData.TYPE_CHART[atk_idx][def_idx]
	return base_modifier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
