extends Control
class_name Shop

signal shop_ended

# The shop will contain this many trinkets
const N_TRINKETS: int = 3

# TODO: introduce varying trinket costs
# For now, every trinket will cost this much
const TRINKET_COST: int = 165

const DISABLED_GRAY: Color = Color(0.545, 0.608, 0.706, 1.0)
const WHITE: Color = Color(1.0, 1.0, 1.0, 1.0)

var trinkets: Array[Trinket] = []
var purchased_trinkets: Array[bool] = []


func setup():
	_roll_trinkets()
	_init_trinket_menu_buttons()
	_render_trinkets()
	_render_player_money()
	%ExitButton.grab_focus()


func _roll_trinkets():
	while trinkets.size() < N_TRINKETS:
		var trinket = GameManager.trinkets_list.trinkets.pick_random()

		# TODO: validate that the player does not have the trinket before adding it to the shop
		# TODO: consider preventing trinkets from appearing in the shop more than once
		# TODO: need a fallback if less than N_TRINKETS trinkets are available
		if !trinkets.has(trinket):
			trinkets.append(trinket)
			purchased_trinkets.append(false)


func _init_trinket_menu_buttons():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i)
		var trinket_button: Button = trinket_entry.get_node("TrinketName")
		var trinket = trinkets[i]
		trinket_button.connect("mouse_entered", func(): trinket_button.grab_focus())
		trinket_button.connect("focus_entered", func(): _on_trinket_focus(i))
		trinket_button.connect("focus_exited", _on_trinket_focus_exit)
		trinket_button.connect("mouse_exited", _on_trinket_focus_exit)
		trinket_button.pressed.connect(func(): _on_trinket_button_pressed(i))


func _render_trinkets():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i)
		trinket_entry.get_node("TrinketName").text = trinkets[i].trinket_name
		trinket_entry.get_node("TrinketIcon").texture = trinkets[i].icon
		trinket_entry.get_node("TrinketCost").text = "¶ %d" % TRINKET_COST


func _render_player_money():
	%Money.text = "¶ %d" % GameManager.player.money


# When a trinket is focused, show its information (name, icon, description,
# cost) on the right side of the shop UI
func _on_trinket_focus(trinket_index: int):
	var trinket: Trinket = trinkets[trinket_index]

	%TrinketInfo.text = trinket.description
	%TrinketIconEnlarged.texture = trinket.icon
	%TrinketName.text = trinket.trinket_name
	%TrinketCost.text = "¶ %d" % TRINKET_COST

	var trinket_cost_label = %TrinketNameAndCost/TrinketCost

	# If the trinket has been purchased, show its icon in gray and cross out the cost
	if purchased_trinkets[trinket_index]:
		trinket_cost_label.text = "[s]%s[/s]" % trinket_cost_label.text
		trinket_cost_label.add_theme_color_override("default_color", DISABLED_GRAY)

		%TrinketIconEnlarged.material = load("res://assets/shaders/grayscale-material.tres")
	else:
		trinket_cost_label.add_theme_color_override("default_color", WHITE)

	%TrinketInfo.show()
	%TrinketIconEnlarged.show()
	%TrinketName.show()
	%TrinketCost.show()


func _on_trinket_focus_exit():
	%TrinketInfo.hide()
	%TrinketIconEnlarged.hide()
	%TrinketIconEnlarged.material = null
	%TrinketName.hide()
	%TrinketCost.hide()


func _on_trinket_button_pressed(trinket_index: int):
	var trinket: Trinket = trinkets[trinket_index]
	var trinket_button: Button = %TrinketContainer.get_child(trinket_index).get_node("TrinketName")
	var trinket_cost_label: RichTextLabel = %TrinketContainer.get_child(trinket_index).get_node("TrinketCost")
	var trinket_icon: TextureRect = %TrinketContainer.get_child(trinket_index).get_node("TrinketIcon")

	if GameManager.player.money < TRINKET_COST:
		return

	# when the trinket is purchased:
	# - disable its button
	# - draw a line through the cost
	# - render its icon in black-and-white
	trinket_button.disabled = true
	trinket_cost_label.text = "[s]%s[/s]" % trinket_cost_label.text
	trinket_cost_label.add_theme_color_override("default_color", DISABLED_GRAY)
	trinket_icon.material = load("res://assets/shaders/grayscale-material.tres")

	# on the right-side summary of the trinket:
	# - draw a line through the cost
	# - render its icon in black-and-white
	var summary_trinket_cost_label = %TrinketNameAndCost/TrinketCost
	summary_trinket_cost_label.text = "[s]%s[/s]" % summary_trinket_cost_label.text
	summary_trinket_cost_label.add_theme_color_override("default_color", DISABLED_GRAY)
	%TrinketIconEnlarged.material = load("res://assets/shaders/grayscale-material.tres")

	# charge the player for the trinket
	GameManager.player.money -= TRINKET_COST
	_render_player_money()

	# Give the trinket to the player, apply it, and redisplay the trinket shelf
	GameManager.player.trinkets.append(trinket)
	trinket.strategy.ApplyEffect(GameManager.player.selected_monster)
	GameManager.player.emit_trinkets_updated_signal()
	%TrinketShelf.render_trinkets()

	purchased_trinkets[trinket_index] = true


func _on_exit_button_pressed() -> void:
	shop_ended.emit()
