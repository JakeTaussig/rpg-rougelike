class_name move extends Resource

enum Types {Human, Fire, Water, Plant, Plasma, Dark, Light}

enum MoveCategory {ATK, SP_ATK, EFFECT, STAT_MODIFIER}

var move_name = "Flamethrower"

var type: Types = Types.Human

var modifier: MoveCategory = MoveCategory.ATK

var accuracy: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
