class_name NazarTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	monster.status_effect_turn_counter = 3

	monster.connect("status_effect_turn_counter_updated", func():
		if monster.status_effect_turn_counter < 3:
			monster.status_effect_turn_counter = 3
	)
