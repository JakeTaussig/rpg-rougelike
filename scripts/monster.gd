class_name Monster
extends Resource

@export var character_name: String = "Monster"
@export var texture: CompressedTexture2D = preload("res://assets/sprites/characters/oddesque.png")

@export var max_hp: int = 100:
	set(new_max_hp):
		max_hp = max(1, new_max_hp)
		hp = min(hp, max_hp) # Clamp down hp if max_hp is decreased. 
@export var hp: int = 100:
	set(new_hp):
		hp = clamp(new_hp, 0, max_hp) # hp can never exceed max_hp
		if new_hp <= 0:
			is_alive = false
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
		crit_chance = crit_chance

@export var crit_chance = 0.02:
	# crit_chance caps at 30% by default
	set(new_crit_chance):
		crit_chance = new_crit_chance

		var crit_chance_mult = float(luck) / 10
		crit_chance = max(crit_chance, crit_chance_mult * 0.02)
		crit_chance = min(0.3, crit_chance)

var crit_factor: float = 2.0;

@export var type: MovesList.Type
@export var moves: Array[Move] = []

var is_alive = true
var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE
var status_effect_turn_counter: int = 0
var consume_benefactor: Monster = null
var is_player = true

func increment_health(value: int) -> void:
	hp += value

func use_move(index: int, target: Monster) -> AttackResults:
	# This is done here rather than in EnactStatuses.gd so that speed doesn't have an impact on how long status effects will last.
	# This will need to be adjusted should the possiblity of using 2 moves on a single turn come into play. 
	if status_effect != MovesList.StatusEffect.NONE:
		status_effect_turn_counter += 1
	var move = moves[index]
	move.pp -= 1
	var move_hit: bool = 1
	var status_applied: bool = 0
	var damage = 0
	var is_critical := false
	if status_effect == MovesList.StatusEffect.WHIRLPOOL:
		# Whirlpool has a 50% chance to damage the affected character each turn
		var whirlpool_activation_chance = 50
		move_hit = _does_move_hit_or_crit(whirlpool_activation_chance)
		if move_hit:
			move = GameManager.get_move_by_name("Whirlpool")
			var results = _attack(move, self, 1)
			return AttackResults.new(move, max(1, results["damage"]), move_hit, status_applied, results["is_critical"])

	elif status_effect == MovesList.StatusEffect.PARALYZE:
		# 33% chance for paralysis to activate
		var paralyze_activation_chance = 33
		move_hit = _does_move_hit_or_crit(paralyze_activation_chance)
		if move_hit:
			move = GameManager.get_move_by_name("Paralyzed")
			damage = 0
			return AttackResults.new(move, damage, move_hit, status_applied, false)

	move_hit = _does_move_hit_or_crit(move.acc)
	
	if move_hit:

		if move.category == Move.MoveCategory.ATK:
			var results = _attack(move, target, 1)
			damage = max(1, results["damage"])
			is_critical = results["is_critical"]
		elif move.category == Move.MoveCategory.SP_ATK:
			var results = _attack(move, target, 0)
			damage = max(1, results["damage"])
			is_critical = results["is_critical"]
		if move.status_effect != MovesList.StatusEffect.NONE:
			status_applied = _roll_and_apply_status_effect(move, target)
	return AttackResults.new(move, damage, move_hit, status_applied, is_critical)
	
func _does_move_hit_or_crit(accuracy: int) -> bool:
	if status_effect == MovesList.StatusEffect.BLIND:
		accuracy = int(float(accuracy) * 0.5)
	accuracy = clamp(accuracy, 0, 100)
	# Generates a number between 1 and 100
	var roll = randi() % 100 + 1
	return roll <= accuracy
	
func _attack(move: Move, target: Monster, is_physical: bool) -> AttackResults:
	var power = move.base_power
	var damage = 0
	var effectiveness_modifier = get_move_effectiveness(move, target)
	var is_critical = _does_move_hit_or_crit(crit_chance * 100)
	if is_physical:
		power = power * atk
		damage = float(power) / target.def
		damage *= effectiveness_modifier
	else:
		power = power * sp_atk
		damage = float(power) / target.sp_def
		damage *= effectiveness_modifier
	if is_critical:
		damage *= crit_factor

	var int_damage = int(damage)

	target.hp -= int_damage

	return AttackResults.new(move, int_damage, true, false, is_critical)

func _roll_and_apply_status_effect(move: Move, target: Monster) -> bool:
	var effect = move.status_effect
	var target_type = target.type
	var is_immune = _check_status_immunity(effect, target_type)
	if is_immune:
		return false
	# Only attempt to apply a status effect if one is not already applied
	if target.status_effect == MovesList.StatusEffect.NONE:
		var status_applied = _does_move_hit_or_crit(move.status_effect_chance)
		if status_applied:
			target.status_effect = move.status_effect
			if target.status_effect == MovesList.StatusEffect.CONSUME:
				target.consume_benefactor = self
			return true
	return false
	
func _check_status_immunity(effect: MovesList.StatusEffect, target_type: MovesList.Type):
	match effect:
		MovesList.StatusEffect.BURN:
			if target_type == MovesList.Type.FIRE:
				return true
		MovesList.StatusEffect.WHIRLPOOL:
			if target_type == MovesList.Type.WATER:
				return true
		MovesList.StatusEffect.POISON:
			if target_type == MovesList.Type.PLANT:
				return true
		MovesList.StatusEffect.PARALYZE:
			if target_type == MovesList.Type.PLASMA:
				return true
		MovesList.StatusEffect.CONSUME:
			if target_type == MovesList.Type.DARK:
				return true
		MovesList.StatusEffect.BLIND:
			if target_type == MovesList.Type.LIGHT:
				return true
	return false
		
func get_move_effectiveness(move: Move,  defender: Monster) -> float:
	var same_type_attack_bonus: float = 1.5 if self.type == move.type else 1.0
	var base_modifier = get_effectiveness_modifier(move, defender)
	return base_modifier * same_type_attack_bonus
	
func get_effectiveness_modifier(move: Move, defender: Monster) -> float:
	var atk_idx = MovesList.TYPES[move.type]
	var def_idx = MovesList.TYPES[defender.type]
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
			if consume_benefactor.is_alive:
				return _recover_from_consume()
		MovesList.StatusEffect.BLIND:
			return _recover_from_blind()
	return ""

# Only called on first turn of cripple
func enact_cripple_on_self():
	if status_effect_turn_counter == 0:
		atk = int(float(atk) * 0.8)
		sp_atk = int(float(sp_atk) * 0.8)
		def = int(float(def) * 0.8)
		sp_def = int(float(sp_def) * 0.8)
		speed = int(float(speed) * 0.8)
		luck = int(float(luck) * 0.8)
		return "All of %s's stats were lowered by 20" % character_name + "%!"
	return ""

func _recover_from_cripple():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	atk = int(float(atk) * 1.25)
	sp_atk = int(float(sp_atk) * 1.25)
	def = int(float(def) * 1.25)
	sp_def = int(float(sp_def) * 1.25)
	speed = int(float(speed) * 1.25)
	luck = int(float(luck) * 1.25)
	return "%s recovered from cripple and their stats were restored!" % character_name

func enact_burn_on_self():
	if status_effect_turn_counter == 0:
		atk = int(float(atk) * 0.5)
		return "%s's attack was lowered by 50" % character_name + "%!"
	else:
		var hp_to_lose = int(max_hp * 0.04)
		hp -= hp_to_lose
		return "%s took %s damage from burn!" % [character_name, str(hp_to_lose)]
	
func _recover_from_burn():
	status_effect = MovesList.StatusEffect.NONE
	status_effect_turn_counter = 0
	atk = int(float(atk) * 1.5)

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
	var hp_to_siphen = int(max_hp * 0.04)
	# Can only consume as much HP is missing. 
	var max_hp_to_siphen = consume_benefactor.max_hp - consume_benefactor.hp
	if max_hp_to_siphen == 0:
		return "%s cannot consume because they are at full HP!" % consume_benefactor.character_name
	elif max_hp_to_siphen < hp_to_siphen:
		hp_to_siphen = max_hp_to_siphen
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

# Inner class. Used for bundling move results
class AttackResults:
	var move: Move
	var damage: int
	var move_hit: bool
	var status_applied: bool
	var is_critical: bool

	func _init(_move: Move, _damage: int, _move_hit: bool, _status_applied: bool, _is_critical: bool):
		move = _move
		damage = _damage
		move_hit = _move_hit
		status_applied = _status_applied
		is_critical = _is_critical
