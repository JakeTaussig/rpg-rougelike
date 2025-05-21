extends Node2D
var turn: int = 0
var turn_order_index: int = 0
var battle_participants = []
enum State {SELECTING_ACTION, SELECTING_ATTACK, ENEMY_ATTACK, ATTACKING_INFO, INCREMENT_TURN, GAME_END}
var state: State = State.SELECTING_ACTION
var lastFocusedMoveIndex: int = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_battle_participants()
	_init_moves()
	_render_hp()
	if battle_participants[turn_order_index].is_player:
		_update_state(State.SELECTING_ACTION, ["What will %s do?" % %Player.character_name])
	else:
		_update_state(State.ENEMY_ATTACK)

# The label_text can be turned into an Array of strings if we end up needing to pass multiple messages.
func _update_state(new_state: State, messages: Array = []):
	var old_state = state
	state = new_state
	%StateDisplay.text = State.keys()[state]
	%TurnDisplay.text = "trn: %s idx: %s" % [turn, turn_order_index]
	if old_state == State.SELECTING_ACTION:
		%PlayerPrompt.visible = false
		%Action.visible = false
		
	elif old_state == State.SELECTING_ATTACK:
		%Moves.visible = false
		
	elif old_state == State.ATTACKING_INFO:
		%BattleStatus.visible = false
		%ContinueButton.release_focus()
		if %Enemy.hp <= 0:
			%BattleStatus.text = "%s defeated %s" % [%Player.character_name, %Enemy.character_name]
			_update_state(State.GAME_END)
			return
		elif %Player.hp <= 0:
			%BattleStatus.text = "%s defeated %s" % [%Enemy.character_name, %Player.character_name]
			_update_state(State.GAME_END)
			return
			
	if state == State.SELECTING_ACTION:
		%PlayerPrompt.visible = true
		%PlayerPrompt.text = messages[0]
		%Action.visible = true
		%Action.get_child(0).grab_focus()
		
	elif state == State.SELECTING_ATTACK:
		_render_moves()
		%Moves.visible = true
		%MovesMenu.get_child(lastFocusedMoveIndex).grab_focus()
		
	elif state == State.ENEMY_ATTACK:
		var enemy = battle_participants[turn_order_index]
		var enemyMoveIdx = enemy.select_move()
		if enemyMoveIdx != -1:
			_on_move_selected(enemyMoveIdx, %Player)
		else:
			_update_state(State.ATTACKING_INFO, ["%s can't attack!" % enemy.character_name])
			
	elif state == State.ATTACKING_INFO:
		_render_hp()
		var index = 0
		for message in messages:
			index += 1
			%BattleStatus.visible = true
			%BattleStatus.text = message
			if not index == messages.size():
				await _wait_for_action("ui_accept")
		%BattleStatus.visible = true
		%ContinueButton.grab_focus()
		
	elif state == State.INCREMENT_TURN:
		turn_order_index += 1
		if turn_order_index == battle_participants.size():
			turn_order_index = 0
			turn += 1
		if battle_participants[turn_order_index].is_player:
			_update_state(State.SELECTING_ACTION, ["What will %s do?" % %Player.character_name])
		else:
			_update_state(State.ENEMY_ATTACK)
			
	elif state == State.GAME_END:
		%BattleStatus.visible = true
		%ContinueButton.grab_focus()

func _init_battle_participants():
	for enemy in %Enemies.get_children():
		enemy.is_player = false
		battle_participants.append(enemy)
	battle_participants.append(%Player)
	battle_participants.sort_custom(func(a, b): 
		if a.speed == b.speed:
			return  randi() % 2 == 0
		return a.speed > b.speed)

func _init_moves():
	for i in %Player.moves.size():
		%MovesMenu.get_child(i).text = %Player.moves[i].move_name
		%MovesMenu.get_child(i).focus_entered.connect(func(): _display_pp_info(i))
		%MovesMenu.get_child(i).mouse_entered.connect(%MovesMenu.get_child(i).grab_focus)

func _on_move_pressed(index: int) -> void:
	var move = %Player.moves[index]
	if move.pp > 0:
		_on_move_selected(index, %Enemy)
	
func _on_move_selected(index: int, target: BattleParticipant) -> void:
	var messages = []
	var attacker: BattleParticipant = battle_participants[turn_order_index]
	var results = attacker.use_move(index, target)
	var used_move_name = results["move"].move_name
	var damage = results["damage"]
	var move_hit = results["move_hit"]
	if not move_hit:
		messages.append("%s missed %s!" % [attacker.character_name, used_move_name])
	elif damage > 0:
		var effectiveness_multiplier: float = attacker.get_effectiveness_modifier(attacker.moves[index], target)
		messages.append("%s used %s on %s for %d damage!" % [attacker.character_name, used_move_name, target.character_name, damage])

		if effectiveness_multiplier > 1.0:
			messages.append("%s was super effective!" % used_move_name)

		elif effectiveness_multiplier < 1.0:
			messages.append("%s was not very effective!" % used_move_name)

	# This should only be status effects for now
	else:
		var status_effect_string = String(MovesData.StatusEffect.find_key(target.status_effect)).to_lower()
		messages.append("%s used %s and applied %s on %s!" % [attacker.character_name, used_move_name, status_effect_string, target.character_name])
		
	_update_state(State.ATTACKING_INFO, messages)
		
func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_continue_button_pressed() -> void:
	if state == State.ATTACKING_INFO:
		_update_state(State.INCREMENT_TURN)
	if state == State.GAME_END:
		await _wait_for_action("ui_accept")
		get_tree().quit()

func _on_attack_pressed() -> void:
	if state == State.SELECTING_ACTION:
		_update_state(State.SELECTING_ATTACK)

func _display_pp_info(moveIndex: int) -> void:
	lastFocusedMoveIndex = moveIndex
	var move = %Player.moves[moveIndex]
	%PPInfo.text = "%d / %d" % [move.pp, move.max_pp]
	if move.pp <= 0:
		%PPInfo.set_theme_type_variation("RedTextLabel")
	else:
		%PPInfo.set_theme_type_variation("NoBorderLabel")
	%TypeInfo.text = MovesData.Type.keys()[move.type]

func _render_moves():
	for i in %Player.moves.size():
		var move = %Player.moves[i]
		if move.pp <= 0:
			%MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			%MovesMenu.get_child(i).set_theme_type_variation("Button")
			
func _wait_for_action(action: String):
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed(action):
			break
