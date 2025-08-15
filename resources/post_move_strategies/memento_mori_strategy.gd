class_name MementoMoriPostAttackStrategy
extends PostAttackStrategy


var last_monster_name = ""

# All trinket effects are applied in order on battle start
func ApplyEffect(attackResults: Monster.AttackResults):
	if not attackResults.move_hit:
		return

	if not attackResults.target.is_alive and last_monster_name == "":
		var message = give_player_stat_up(attackResults.attacker)
		return "One hit kill!\n%s" % message

	# if we completed a turn against a monster, store their name
	# if a name is present, we know that there cannot have been a one hit kill
	if attackResults.target.is_alive:
		last_monster_name = attackResults.target.character_name
	else:
		last_monster_name = ""

func give_player_stat_up(monster: Monster) -> String:
	var stat = ["MAX_HP", "ATK", "SP_ATK", "DEF", "SP_DEF", "SPEED", "LUCK"].pick_random()

	match stat:
		"MAX_HP":
			monster.max_hp += 25
			monster.hp += 25
			return "%s's max HP increased  by %d, from %d to %d" % [monster.character_name, 25, monster.max_hp - 25, monster.max_hp]
		"ATK":
			monster.atk += 5
			return "%s's attack increased by %d, from %d to %d" % [monster.character_name, 5, monster.atk - 5, monster.atk]
		"SP_ATK":
			monster.sp_atk += 5
			return "%s's sp. atk increased  by %d, from %d to %d" % [monster.character_name, 5, monster.sp_atk - 5, monster.sp_atk]
		"DEF":
			monster.def += 5
			return "%s's defense increased by %d, from %d to %d" % [monster.character_name, 5, monster.def - 5, monster.def]
		"SP_DEF":
			monster.sp_def += 5
			return "%s's sp. def	for additional_message in results.additional_trinket_messages:
		messages.append(additional_message) increased by %d, from %d to %d" % [monster.character_name, 5, monster.sp_def - 5, monster.sp_def]
		"SPEED":
			monster.speed += 5
			return "%s's speed increased by %d, from %d to %d" % [monster.character_name, 5, monster.speed - 5, monster.speed]
		"LUCK":
			monster.luck += 5
			return "%s's luck increased by %d, from %d to %d" % [monster.character_name, 5, monster.luck - 5, monster.luck]
		_:
			return ""
