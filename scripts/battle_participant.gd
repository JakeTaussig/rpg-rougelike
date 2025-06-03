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
var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE
var status_effect_turn_counter: int = 0
var consume_benefactor: BattleParticipant = null

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
	# This is done here rather than in EnactStatuses.gd so that speed doesn't have an impact on how long status effects will last.
	# This will need to be adjusted should the possiblity of using 2 moves on a single turn come into play. 
	if status_effect != MovesList.StatusEffect.NONE:
		status_effect_turn_counter += 1
	var move = moves[index]
	move.pp -= 1
	var move_hit: bool = 1
	var status_applied: bool = 0
	var damage = 0
	if status_effect ==  MovesList.StatusEffect.WHIRLPOOL:
		# Whirlpool has a 50% chance to damage the affected character each turn
		move_hit = _does_move_hit(50)
		if move_hit:
			move = GameManager.get_move_by_name("Whirlpool")
			damage = max(1, _attack(move, self, 1))
			return {"move": move, "damage": damage, "move_hit": 1, "status_applied": 0}
	
	elif status_effect == MovesList.StatusEffect.PARALYZE:
		# 33% chance for paralysis to activate
		move_hit = _does_move_hit(33)
		if move_hit:
			move = GameManager.get_move_by_name("Paralyzed")
			damage = 0
			return {"move": move, "damage": damage, "move_hit": 1, "status_applied": 0}
	move_hit = _does_move_hit(move.acc)
	
	if move_hit:
		if move.category == Move.MoveCategory.ATK:
			damage = max(1, _attack(move, target, 1))
		elif move.category == Move.MoveCategory.SP_ATK:
			damage = max(1, _attack(move, target, 0))
		if move.status_effect != MovesList.StatusEffect.NONE:
			status_applied = _roll_and_apply_status_effect(move, target)
	return {"move": move, "damage": damage, "move_hit": move_hit, "status_applied": status_applied}

func _does_move_hit(accuracy: int) -> bool:
	if status_effect == MovesList.StatusEffect.BLIND:
		accuracy = accuracy * 0.67
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
	
func _roll_and_apply_status_effect(move: Move, target: BattleParticipant) -> bool:
	# Only attempt to apply a status effect if one is not already applied
	if target.status_effect == MovesList.StatusEffect.NONE:
		var status_applied = _does_move_hit(move.status_effect_chance)
		if status_applied:
			target.status_effect = move.status_effect
			if target.status_effect == MovesList.StatusEffect.CONSUME:
				target.consume_benefactor = self
			return true
	return false
		
func get_move_effectiveness(move: Move,  defender: BattleParticipant) -> float:
	var same_type_attack_bonus: float = 1.5 if self.monster.type == move.type else 1.0
	var base_modifier = get_effectiveness_modifier(move, defender)
	return base_modifier * same_type_attack_bonus
	
func get_effectiveness_modifier(move: Move, defender: BattleParticipant) -> float:
	var atk_idx = MovesList.TYPES[move.type]
	var def_idx = MovesList.TYPES[defender.monster.type]
	var base_modifier = MovesList.TYPE_CHART[atk_idx][def_idx]
	return base_modifier
	
func enact_status_effect() -> String:
	match status_effect:
		MovesList.StatusEffect.CRIPPLE:
			return enact_cripple_on_self()
		MovesList.StatusEffect.BURN:
			return enact_burn_on_self()
		MovesList.StatusEffect.POISON:
			return enact_poison_on_self()
		MovesList.StatusEffect.CONSUME:
			return enact_consume_on_self()
	return ""
	
func recover_from_status_effect() -> String:
	match status_effect:
		MovesList.StatusEffect.CRIPPLE:
			return _recover_from_cripple()
		MovesList.StatusEffect.BURN:
			return _recover_from_burn()
		MovesList.StatusEffect.WHIRLPOOL:
			return _recover_from_whirlpool()
		MovesList.StatusEffect.POISON:
			return _recover_from_poison()
		MovesList.StatusEffect.PARALYZE:
			return _recover_from_paralyze()
		MovesList.StatusEffect.CONSUME:
			return _recover_from_consume()
		MovesList.StatusEffect.BLIND:
			return _recover_from_blind()
	return ""

# Only called on first turn of cripple
func enact_cripple_on_self():
	if status_effect_turn_counter == 0:
		atk *= 0.8
		sp_atk *= 0.8
		def *= 0.8
		sp_def *= 0.8
		speed *= 0.8
		luck *= 0.8
		return "All of %s's stats were lowered by 20" % character_name + "%!"
	return ""

func _recover_from_cripple():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	atk *= 1.25
	sp_atk *= 1.25
	def *= 1.25
	sp_def *= 1.25
	speed *= 1.25
	luck *= 1.25
	return "%s recovered from cripple and their stats were restored!" % character_name
	
func enact_burn_on_self():
	if status_effect_turn_counter == 0:
		atk *= 0.5
		return "%s's attack was lowered by 50" % character_name + "%!"
	else:
		var hp_to_lose = int(max_hp * 0.04)
		hp -= hp_to_lose
		return "%s took %s damage from burn!" % [character_name, str(hp_to_lose)]
	
func _recover_from_burn():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	atk *= 1.5
	return "%s recovered from burn!" % character_name
	
func _recover_from_whirlpool():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	return "%s recovered from whirlpool!" % character_name

func enact_poison_on_self():
	var hp_to_lose = int(max_hp * 0.08)
	hp -= hp_to_lose
	return "%s is poisoned and took %s damage!" % [character_name, hp_to_lose]
	
func _recover_from_poison():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	return "%s recovered from poison" % character_name
	
func _recover_from_paralyze():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	return "%s recovered from paralyze" % character_name
	
func enact_consume_on_self():
	var hp_to_siphen = max_hp * 0.04
	hp -= hp_to_siphen
	consume_benefactor.hp += hp_to_siphen
	return "%s consumed %s HP from %s!" % [consume_benefactor.character_name, str(hp_to_siphen), character_name]
	
func _recover_from_consume():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	consume_benefactor = null
	return "%s recovered from consume!" % character_name
	
func _recover_from_blind():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	return "%s recovered from blind!" % character_name
