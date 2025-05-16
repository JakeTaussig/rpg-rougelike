extends Node2D
var moves_list = MovesList.new()
var turn: int = 0
var turn_order_index: int = 0
var battle_participants = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy in %Enemies.get_children():
		enemy.speed = 20
		enemy.is_player = false
		battle_participants.append(enemy)
	battle_participants.append(%Player)
	battle_participants.sort_custom(func(a, b): return a.speed - b.speed)
	_render_hp()
	_start_battle()
	for i in %Player.moves.size():
		%Attack.get_child(i).text = %Player.moves[i].move_name
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Enemy " + str(%Player.hp) + " / " + str(%Player.max_hp)
	pass
	
func _start_battle():
	if battle_participants[turn_order_index].is_player:
		%Action.get_child(0).grab_focus()
	else:
		_enemy_turn()
func _on_attack_pressed() -> void:
	%Action.visible = false
	%Attack.visible = true
	%Attack.get_child(0).grab_focus()
	
func _on_move_pressed(index: int) -> void:
	%Player.use_move(index, %Enemy)
	_increment_turn()

func _increment_turn():
	%Action.visible = true
	%Attack.visible = false
	_render_hp()
	turn_order_index += 1
	if turn_order_index == battle_participants.size():
		turn_order_index = 0
		turn += 1
	if battle_participants[turn_order_index].is_player:
		%Action.get_child(0).grab_focus()
	else:
		_enemy_turn()
		
func _enemy_turn():
	%Enemy.use_move(0, %Player)
	_increment_turn()
	
