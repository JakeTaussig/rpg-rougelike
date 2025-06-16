class_name CallableStateMachine

var state_dictionary = {}
var current_state: String


func add_states(
	normal_state_callable: Callable,
	enter_state_callable: Callable,
	leave_state_callable: Callable
):
	state_dictionary[normal_state_callable.get_method()] = {
		"normal": normal_state_callable,
		"enter": enter_state_callable,
		"leave": leave_state_callable
	}


func set_initial_state(state_callable: Callable):
	var state_name = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state(state_name)
	else:
		push_warning("No state with name " + state_name)


func update():
	if current_state != null:
		(state_dictionary[current_state].normal as Callable).call()


func change_state(state_callable: Callable):
	var state_name = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state.call_deferred(state_name)
	else:
		push_warning("No state with name " + state_name)


func _set_state(state_name: String):
	if current_state:
		var leave_callable = state_dictionary[current_state].leave as Callable
		if !leave_callable.is_null():
			leave_callable.call()
	
	current_state = state_name
	var enter_callable = state_dictionary[current_state].enter as Callable
	if !enter_callable.is_null():
		enter_callable.call()
		
# Use like so:
#var state_machine: CallableStateMachine = CallableStateMachine.new()
#
#
#func _ready():
	#state_machine.add_states(state_normal, enter_state_normal, Callable())
	#state_machine.add_states(state_abnormal, Callable(), Callable())
	#state_machine.set_initial_state(state_normal)
#
#
#func _process(_delta):
	#state_machine.update()
#
#
#func enter_state_normal():
	#print("entering state normal")
#
#
#func state_normal():
	#print("doing state normal")
  	#if some_condition:
		#state_machine.change_state(state_abnormal)
#
#
#func leave_state_normal():
	## empty, will not be called unless added to the state machine as the third argument to state_machine.add_states
	#pass
#
#
#func state_abnormal():
	#print("in state abnormal")
