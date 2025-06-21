class_name Trinket extends Resource

# Determines when and where the trinket's effect is applied
enum TrinketCategory { ATK, TYPE }
@export var trinket_name: String = "Transform"
@export var icon: CompressedTexture2D = load("res://assets/sprites/trinket_icons/skull.png")
@export var description: String = "Change the player's type"
@export var category: TrinketCategory = TrinketCategory.TYPE

@export var callback_name: String:
	set(_name):
		callback_name = _name
		if _name == "":
			_callback = Callable()
		elif has_method(_name):
			_callback = Callable(self, _name)
		else:
			push_error("Callback method '%s' not found in Item" % _name)
			_callback = Callable()
var _callback: Callable


func apply_effect():
	return _callback.call()

func _change_type_to_fire() -> MovesList.Type:
	
	return MovesList.Type.FIRE

func _change_type_to_human() -> MovesList.Type:
	return MovesList.Type.HUMAN
