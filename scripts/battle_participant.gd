@tool
extends Sprite2D
class_name BattleParticipant

@export var monster: Monster = preload("res://assets/monsters/omenite.tres"):
	set(new_monster):
		monster = new_monster
		_render_battler()

var is_player = true:
	set(_is_player):
		is_player = _is_player
		_render_battler()

var moves: Array[Move] = []
var status_effect = MovesList.StatusEffect.NONE

func _render_battler():
	texture = monster.texture
	flip_h = is_player

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	monster = monster.duplicate()
	_render_battler()
	if not Engine.is_editor_hint():
		for move in GameManager.moves_list.moves.slice(0, 4):
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
		if move.status_effect != MovesList.StatusEffect.NONE:
			_roll_and_apply_status_effect(move, target)
	return {"move": move, "damage": damage, "move_hit": move_hit}

func _does_move_hit(accuracy: int) -> bool:
	accuracy = clamp(accuracy, 0, 100)
	# Generates a number between 1 and 100
	var roll = randi() % 100 + 1
	return roll <= accuracy
	
func increment_health(value: int) -> void:
	monster.hp += value
	
func _attack(move: Move, target: BattleParticipant, is_physical: bool) -> int:
	var power = move.base_power
	var damage = 0
	var effectiveness_modifier = get_move_effectiveness(move, target)
	if is_physical:
		power = power * monster.atk
		damage = power / target.monster.def
		damage *= effectiveness_modifier
	else:
		power = power * monster.sp_atk
		damage = power / target.monster.sp_def
		damage *= effectiveness_modifier
	target.monster.hp -= damage
	return damage
	
func _roll_and_apply_status_effect(move: Move, target: BattleParticipant):
	# Only attempt to apply a status effect if one is not already applied
	if target.status_effect == MovesList.StatusEffect.NONE:
		var status_applied = _does_move_hit(move.status_effect_chance)
		if status_applied:
			target.status_effect = move.status_effect
		
func get_move_effectiveness(move: Move,  defender: BattleParticipant) -> float:
	var same_type_attack_bonus: float = 1.5 if self.monster.type == move.type else 1.0
	var base_modifier = get_effectiveness_modifier(move, defender)
	return base_modifier * same_type_attack_bonus
	
func get_effectiveness_modifier(move: Move, defender: BattleParticipant) -> float:
	var atk_idx = MovesList.TYPES[move.type]
	var def_idx = MovesList.TYPES[defender.monster.type]
	var base_modifier = MovesList.TYPE_CHART[atk_idx][def_idx]
	return base_modifier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
