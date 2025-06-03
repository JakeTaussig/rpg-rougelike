extends BaseState

var last_focused_move_index = 0

func enter(messages: Array = []):
	%Items.visible = true
	%ItemsMenu.get_child(last_focused_move_index).grab_focus()
	_render_moves()

func exit():
	%Moves.visible = false

func _render_moves():
	# placeholder implementation
	%ItemsMenu.get_child(0).text = "HP Restore"
	%ItemQtyInfo.text = "Qty: %d / 99" % %Player.backpack.hp_restore_qty
