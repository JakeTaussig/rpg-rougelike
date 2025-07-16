extends Panel
class_name TrinketShelf

var prior_focused_element: Variant

var on = false

var last_focused_idx = 0

@export var trinket_info_label: RichTextLabel
@export var trinket_info_panel: Panel
@export var trinket_info_sprite: Sprite2D

@export var trinkets: Array[Trinket]


func _ready():
	if trinkets.size() == 0 && GameManager.player != null:
		trinkets = GameManager.player.trinkets

	for i in range(%TrinketIconContainer.get_child_count()):
		var trinket_button: Button = %TrinketIconContainer.get_child(i)
		trinket_button.mouse_entered.connect(func(): steal_focus(i))
		trinket_button.mouse_exited.connect(return_focus)
		trinket_button.focus_entered.connect(func(): _display_trinket_info(i))
		trinket_button.focus_exited.connect(_hide_trinket_info)

	render_trinkets()


func render_trinkets():
	for i in range(trinkets.size()):
		var trinket: Trinket = trinkets[i]
		var trinket_button: Button = %TrinketIconContainer.get_child(i)
		trinket_button.icon = trinket.icon


func _display_trinket_info(index: int):
	if index >= trinkets.size():
		return

	trinket_info_panel.visible = true
	trinket_info_label.visible = true

	var trinket: Trinket = trinkets[index]

	trinket_info_sprite.texture = trinket.icon

	trinket_info_label.text = ("[center]%s[/center]\n%s" % [trinket.trinket_name, trinket.description])
	last_focused_idx = index


func _hide_trinket_info():
	trinket_info_label.hide()
	trinket_info_panel.hide()


func steal_focus(index):
	var focus_owner = get_viewport().gui_get_focus_owner()

	if not %TrinketIconContainer.is_ancestor_of(focus_owner):
		prior_focused_element = focus_owner

	get_child(0).get_child(index).grab_focus()
	on = true


func return_focus():
	if prior_focused_element:
		prior_focused_element.grab_focus()
	else:
		release_focus()
	on = false
