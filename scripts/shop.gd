extends Control
class_name Shop

signal shop_ended

# The shop will contain this many trinkets
const N_TRINKETS: int = 3

# The shop will contain this many consumables
const N_CONSUMABLES: int = 3

const N_PAGES = 2
var page = 0

# TODO: introduce varying trinket costs
# For now, every trinket will cost this much
const TRINKET_COST: int = 165

const CONSUMABLE_COST: int = 100

const DISABLED_GRAY: Color = Color(0.545, 0.608, 0.706, 1.0)
const WHITE: Color = Color(1.0, 1.0, 1.0, 1.0)

var trinkets: Array[Trinket] = []
var purchased_trinkets: Array[bool] = []
var global_ui_manager = GameManager.global_ui_manager

enum CONSUMABLES { HP_RESTORE, PP_RESTORE}
var consumables: Array[CONSUMABLES] = []
var purchased_consumables: Array[bool] = []

func setup():
	_roll_trinkets()
	_roll_consumables()
	_init_trinket_menu_buttons()
	_init_consumable_menu_buttons()
	_render_trinkets()
	_render_consumables()

	%TrinketContainer.show()
	%ConsumableContainer.hide()


	_render_player_prana()
	GameManager.player.selected_monster.tracker.visible = true
	%ExitButton.grab_focus()


func _roll_trinkets():
	while trinkets.size() < N_TRINKETS:
		var trinkets_list = GameManager.trinkets_list.trinkets
		var trinkets_list_copy = []
		# Trinkets the player has can't be added to the shop
		for trinket in trinkets_list:
			if not GameManager.player.selected_monster.trinkets.has(trinket):
				trinkets_list_copy.append(trinket)
		
		var trinket = trinkets_list_copy.pick_random()

		if !trinkets.has(trinket):
			trinkets.append(trinket)
			purchased_trinkets.append(false)

func _roll_consumables():
	while consumables.size() < N_CONSUMABLES:
		var consumable_options: Array[CONSUMABLES] = [CONSUMABLES.HP_RESTORE, CONSUMABLES.PP_RESTORE]
		var consumable = consumable_options.pick_random()

		consumables.append(consumable)
		purchased_consumables.append(false)


func _init_trinket_menu_buttons():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i)
		var trinket_button: Button = trinket_entry.get_node("TrinketName")
		trinket_button.connect("mouse_entered", func(): trinket_button.grab_focus())
		trinket_button.connect("focus_entered", func(): _on_trinket_focus(i))
		trinket_button.connect("focus_exited", _on_trinket_focus_exit)
		trinket_button.connect("mouse_exited", _on_trinket_focus_exit)
		trinket_button.pressed.connect(func(): _on_trinket_button_pressed(i))

func _init_consumable_menu_buttons():
	for i in range(N_CONSUMABLES):
		var consumable_entry: HBoxContainer = %ConsumableContainer.get_child(i)
		var consumable_button: Button = consumable_entry.get_node("ConsumableName")
		consumable_button.connect("mouse_entered", func(): consumable_button.grab_focus())
		consumable_button.pressed.connect(func(): _on_consumable_button_pressed(i))

func _on_consumable_button_pressed(i: int):
		if GameManager.player.prana < CONSUMABLE_COST:
			return

		# If the Moves menu (Used for PP restores)  is already up, close it before processing another consumable
		if $Moves.visible:
			$Moves.exit()
			$Moves.hide()

		if consumables[i] == CONSUMABLES.HP_RESTORE:
			if GameManager.player.selected_monster.hp == GameManager.player.selected_monster.max_hp:
				return
			GameManager.player.selected_monster.hp += 50
			mark_consumable_sold(i)

		elif consumables[i] == CONSUMABLES.PP_RESTORE:
			# pop up the list of player moves.
			# if the player selects one, restore 5 PP to that move
			# if the player chooses to go back, don't charge the player
			var moves = $Moves
			moves.show()

			%Tracker.hide()
			%ConsumableExitButton.hide()

			var on_move_button_pressed = func(move_index: int):
				var move = GameManager.player.selected_monster.moves[move_index]
				if move.pp >= move.max_pp:
					return

				if purchased_consumables[i]:
					return

				move.pp = min(move.pp + 5, move.max_pp)
				mark_consumable_sold(i)
				# we needs to disable the move buttons after the move has been sold
				# so that you can't repeatedly click the button to restore PP
				moves.disable_all_buttons()
			var is_move_disabled = func(move: Move):
				return move.pp == move.max_pp

			moves.enter(on_move_button_pressed, is_move_disabled)

func mark_consumable_sold(i: int):
		var consumable_button: Button = %ConsumableContainer.get_child(i).get_node("ConsumableName")
		var consumable_cost_label: RichTextLabel = %ConsumableContainer.get_child(i).get_node("ConsumableCost")
		var consumable_icon: TextureRect = %ConsumableContainer.get_child(i).get_node("ConsumableIcon")

		# charge the player for the trinket
		GameManager.player.prana -= CONSUMABLE_COST
		_render_player_prana()

		# when the consumable is purchased:
		# - disable its button
		# - draw a line through the cost
		# - render its icon in black-and-white
		# - re-render the tracker
		consumable_button.disabled = true
		consumable_cost_label.text = "[s]%s[/s]" % consumable_cost_label.text
		consumable_cost_label.add_theme_color_override("default_color", DISABLED_GRAY)
		consumable_icon.material = load("res://assets/shaders/grayscale-material.tres")
		purchased_consumables[i] = true
		%Tracker.populate_player_tracker()

func _input(event: InputEvent):
	# the "Back" button in the moves list emits the "ui_cancel" event when pressed
	# the ESC key is also bound to this event
	# we want to close the moves menu (Associated with PP restore consumables)
	# when "ui_cancel" is pressed
	if event.is_action_pressed("ui_cancel"):
		if $Moves.visible:
			$Moves.exit()
			$Moves.hide()

func _render_trinkets():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i)
		trinket_entry.get_node("TrinketName").text = trinkets[i].trinket_name
		trinket_entry.get_node("TrinketIcon").texture = trinkets[i].icon
		trinket_entry.get_node("TrinketCost").text = "¶ %d" % TRINKET_COST

func _render_consumables():
	var HP_icon = load("res://assets/sprites/trinket_icons/heart.png")
	var PP_icon = load("res://assets/sprites/trinket_icons/pp.png")

	for i in range(N_CONSUMABLES):
		var consumable_entry: HBoxContainer = %ConsumableContainer.get_child(i)
		if consumables[i] == CONSUMABLES.HP_RESTORE:
			consumable_entry.get_node("ConsumableName").text = "+50 HP"
			consumable_entry.get_node("ConsumableIcon").texture = HP_icon
		elif consumables[i] == CONSUMABLES.PP_RESTORE:
			consumable_entry.get_node("ConsumableName").text = "+5 PP"
			consumable_entry.get_node("ConsumableIcon").texture = PP_icon

		consumable_entry.get_node("ConsumableCost").text = "¶ %d" % CONSUMABLE_COST

func _render_player_prana():
	%Prana.text = "¶ %d" % GameManager.player.prana


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
	GameManager.player.selected_monster.tracker.hide()


func _on_trinket_focus_exit():
	%TrinketInfo.hide()
	%TrinketIconEnlarged.hide()
	%TrinketIconEnlarged.material = null
	%TrinketName.hide()
	%TrinketCost.hide()
	GameManager.player.selected_monster.tracker.show()


func _on_trinket_button_pressed(trinket_index: int):
	var trinket: Trinket = trinkets[trinket_index]
	var trinket_button: Button = %TrinketContainer.get_child(trinket_index).get_node("TrinketName")
	var trinket_cost_label: RichTextLabel = %TrinketContainer.get_child(trinket_index).get_node("TrinketCost")
	var trinket_icon: TextureRect = %TrinketContainer.get_child(trinket_index).get_node("TrinketIcon")

	if GameManager.player.prana < TRINKET_COST:
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
	GameManager.player.prana -= TRINKET_COST
	_render_player_prana()

	# Give the trinket to the player, apply it, and redisplay the trinket shelf
	GameManager.player.selected_monster.trinkets.append(trinket)
	# Remember to set the HP back to the monster's current hp, but make sure it doesn't exceed the potentially reduced max_hp
	trinket.strategy.ApplyEffect(GameManager.player.selected_monster)
	%TrinketShelf.render_trinkets()
	GameManager.player.selected_monster.tracker.populate_player_tracker()

	purchased_trinkets[trinket_index] = true


func _on_exit_button_pressed() -> void:
	shop_ended.emit()


func _on_swap_page_button_pressed() -> void:
	page += 1
	if page == N_PAGES:
		page = 0

	if page == 0:
		%ConsumableContainer.hide()
		%TrinketContainer.show()
		%ForSaleButton.text = "Trinkets (1/2)"

		if $Moves.visible:
			$Moves.exit()
			$Moves.hide()

	if page == 1:
		%TrinketContainer.hide()
		%ConsumableContainer.show()
		%ForSaleButton.text = "Consumables (2/2)"


func _on_moves_hidden() -> void:
		%Tracker.show()
		%ConsumableExitButton.show()
