extends Panel

var prior_focused_element: Variant

var on = false

var last_focused_idx = 0

@export var trinket_name_label: Label
@export var trinket_info_label: RichTextLabel
@export var trinket_info_panel: Panel

# the trinket icon is displayed via either a Sprite2D or a Texture Rect. only
# one of trinket_info_sprite and trinket_info_texture_rect should be set
@export var trinket_info_sprite: Sprite2D
@export var trinket_info_texture_rect: TextureRect

@export var trinkets: Array[Trinket]

@export var show_trinket_name_on_panel: bool = true


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

	var trinket: Trinket = trinkets[index]

	last_focused_idx = index

	if trinket_info_panel:
		trinket_info_panel.show()

	if trinket_info_label:
		trinket_info_label.show()

	if trinket_name_label:
		trinket_name_label.text = trinket.trinket_name
		trinket_name_label.show()

	if trinket_info_sprite:
		trinket_info_sprite.texture = trinket.icon
		trinket_info_sprite.show()
	elif trinket_info_texture_rect:
		trinket_info_texture_rect.texture = trinket.icon
		trinket_info_texture_rect.show()

	if show_trinket_name_on_panel:
		trinket_info_label.text = ("[center]%s[/center]\n%s" % [trinket.trinket_name, trinket.description])
	else:
		trinket_info_label.text = trinket.description


func _hide_trinket_info():
	trinket_info_label.hide()
	if trinket_info_panel:
		trinket_info_panel.hide()
	if trinket_info_texture_rect:
		trinket_info_texture_rect.hide()


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
