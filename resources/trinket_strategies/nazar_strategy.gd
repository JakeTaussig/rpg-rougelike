class_name NazarTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.status_effect_turn_counter = 2

	monster.connect("status_effect_turn_counter_updated", func():
		if monster.status_effect_turn_counter < 2:
			monster.status_effect_turn_counter = 2
	)
