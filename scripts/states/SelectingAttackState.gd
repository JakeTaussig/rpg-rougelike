extends BaseState

@onready var Moves: Node2D = %Moves
@onready var MovesMenu: GridContainer = %MovesMenu

@onready var PPInfo: Label = %PPInfo
@onready var TypeInfo: Label = %TypeInfo

var lastFocusedMoveIndex: int = 0

func _ready() -> void:
	# initialize move names and connect PP info display
	for i in %Player.moves.size():
		MovesMenu.get_child(i).text = %Player.moves[i].move_name
		MovesMenu.get_child(i).focus_entered.connect(func(): _display_pp_info(i))
		MovesMenu.get_child(i).mouse_entered.connect(MovesMenu.get_child(i).grab_focus)

func enter(messages: Array = []):
	_render_moves()
	Moves.visible = true
	MovesMenu.get_child(lastFocusedMoveIndex).grab_focus()

func exit():
	Moves.visible = false

func _render_moves():
	for i in %Player.moves.size():
		var move = %Player.moves[i]
		if move.pp <= 0:
			MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			MovesMenu.get_child(i).set_theme_type_variation("Button")

func _on_move_pressed(index: int) -> void:
	var move = %Player.moves[index]
	if move.pp > 0:
		battle_system.attack(index, battle_system.enemy)

# callback used when a move is focused
# displays the PP and type of the move in $"Moves/MovesInfo"
func _display_pp_info(moveIndex: int) -> void:
	lastFocusedMoveIndex = moveIndex
	var move = %Player.moves[moveIndex]
	PPInfo.text = "%d / %d" % [move.pp, move.max_pp]
	if move.pp <= 0:
		PPInfo.set_theme_type_variation("RedTextLabel")
	else:
		PPInfo.set_theme_type_variation("NoBorderLabel")
	TypeInfo.text = MovesList.Type.keys()[move.type]
