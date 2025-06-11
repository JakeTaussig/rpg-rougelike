class_name BaseState
extends Node

# TODO: Put a new battle here when the battle is won
var battle: Battle

func enter(_messages: Array = []):
	pass

func exit():
	pass

func handle_continue():
	pass

func handle_input(_event: InputEvent):
	pass
