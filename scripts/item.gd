extends Resource
class_name Item

@export var name: String
@export var qty: int
@export var description: String

@export var callback_name: String:
	set(_name):
		callback_name = _name
		_callback = Callable(self, _name)
var _callback: Callable

static func create(_name: String, _qty: int, _description: String, _callback_name: String):
	var output = Item.new()
	output.name = _name
	output.qty = _qty
	output.description = _description
	output.callback_name = _callback_name
	return output

# returns an identical copy of the current item
func copy() -> Item:
	var new_item = Item.new()
	var properties = get_property_list()

	for property in properties:
		# Only copy custom, writable properties
		var is_custom_property = property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
		var is_writable_property = property.usage & PROPERTY_USAGE_STORAGE
		if is_custom_property and is_writable_property:
			var property_name = property["name"]
			new_item.set(property_name, get(property_name))

	return new_item

func consume(selected_monster, battle):
	if qty <= 0:
		push_error("cannot consume item %s with <= 0 qty" % name)
		return
	qty -= 1

	var output = _callback.call(selected_monster, battle)
	if output:
		qty += 1

func _handle_hp_restore(selected_monster, battle):
	const HP_RESTORE_AMT = 30
	selected_monster.hp += HP_RESTORE_AMT
	battle.transition_state_to(battle.STATE_INFO, ["%s restored 30 HP" % selected_monster.character_name])

func _handle_attack_up(selected_monster, battle):
	const ATK_UP_FACTOR = 1.1
	var prior_atk = selected_monster.atk
	var current_atk = int(ATK_UP_FACTOR * prior_atk)
	selected_monster.atk = current_atk
	battle.transition_state_to(battle.STATE_INFO, ["%s's attack increased from %d to %d" % [selected_monster.character_name, prior_atk, current_atk]])

func _handle_sp_atk_up(selected_monster, battle):
	const SP_ATK_UP_FACTOR = 1.1
	var prior_sp_atk = selected_monster.sp_atk
	var current_sp_atk = int(SP_ATK_UP_FACTOR * prior_sp_atk)
	selected_monster.sp_atk = current_sp_atk
	battle.transition_state_to(battle.STATE_INFO, ["%s's special attack increased from %d to %d" % [selected_monster.character_name, prior_sp_atk, current_sp_atk]])

func _handle_def_up(selected_monster, battle):
	const DEF_UP_FACTOR = 1.1
	var prior_def = selected_monster.def
	var current_def = int(DEF_UP_FACTOR * prior_def)
	selected_monster.def = current_def
	battle.transition_state_to(battle.STATE_INFO, ["%s's defense increased from %d to %d" % [selected_monster.character_name, prior_def, current_def]])

func _handle_sp_def_up(selected_monster, battle):
	const SP_DEF_UP_FACTOR = 1.1
	var prior_sp_def = selected_monster.sp_def
	var current_sp_def = int(SP_DEF_UP_FACTOR * prior_sp_def)
	selected_monster.sp_def = current_sp_def
	battle.transition_state_to(battle.STATE_INFO, ["%s's special defense increased from %d to %d" % [selected_monster.character_name, prior_sp_def, current_sp_def]])

func _handle_speed_up(selected_monster, battle):
	const SPEED_UP_FACTOR = 1.1
	var prior_speed = selected_monster.speed
	var current_speed = int(SPEED_UP_FACTOR * prior_speed)
	selected_monster.speed = current_speed
	battle.transition_state_to(battle.STATE_INFO, ["%s's speed increased from %d to %d" % [selected_monster.character_name, prior_speed, current_speed]])

func _handle_luck_up(selected_monster, battle):
	const LUCK_UP_FACTOR = 1.1
	var prior_luck = selected_monster.luck
	var current_luck = int(LUCK_UP_FACTOR * prior_luck)
	selected_monster.luck = current_luck
	battle.transition_state_to(battle.STATE_INFO, ["%s's luck increased from %d to %d" % [selected_monster.character_name, prior_luck, current_luck]])

func _handle_burn_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.BURN:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s healed their BURN" % selected_monster.character_name])
	else:
		return true # return the item to the player

func _handle_cripple_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.CRIPPLE:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s recovered from CRIPPLE" % selected_monster.character_name])
	else:
		return true # return the item to the player

func _handle_whirlpool_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.WHIRLPOOL:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s escaped the WHIRLPOOL" % selected_monster.character_name])
	else:
		return true # return the item to the player


func _handle_poison_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.POISON:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s was cured of POISON" % selected_monster.character_name])
	else:
		return true # return the item to the player


func _handle_paralyze_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.PARALYZE:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s recovered from PARALYZE" % selected_monster.character_name])
	else:
		return true # return the item to the player


func _handle_consume_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.CONSUME:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s regained their energy" % selected_monster.character_name])
	else:
		return true # return the item to the player


func _handle_blind_heal(selected_monster, battle):
	if selected_monster.status_effect == MovesList.StatusEffect.BLIND:
		selected_monster.recover_from_status_effect()
		battle.transition_state_to(battle.STATE_INFO, ["%s's vision was restored" % selected_monster.character_name])
	else:
		return true # return the item to the player


func _handle_pp_restore(selected_monster, battle):
	var all_moves_full_pp = true
	for move: Move in selected_monster.moves:
		if move.pp < move.max_pp:
			all_moves_full_pp = false
			break

	if all_moves_full_pp:
		return true # return the item to the player


	battle.transition_state_to(battle.STATE_SELECTING_ATTACK_PP_RESTORE)
