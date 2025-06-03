extends Resource
class_name Backpack
# the Backpack contains all consumable items for a given battle participant.
# The Player's Backpack is intended to be saved across multiple battles

const HP_RESTORE_AMT = 30 # value in HP
@export var hp_restore_qty = 0:
	set(new_hp_restore_qty):
		hp_restore_qty = min(99, new_hp_restore_qty)

func consume_hp_restore(consumer: Monster):
	if hp_restore_qty <= 0:
		push_error("cannot heal with <=0 hp_restore_qty")
		return false
	hp_restore_qty -= 1
	consumer.hp += HP_RESTORE_AMT
	return true
