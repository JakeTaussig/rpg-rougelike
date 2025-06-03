extends Resource
class_name Backpack
# the Backpack contains all consumable items for a given battle participant.
# The Player's Backpack is intended to be saved across multiple battles

@export var hp_restore_qty = 0:
	set(new_hp_restore_qty):
		hp_restore_qty = min(99, new_hp_restore_qty)
