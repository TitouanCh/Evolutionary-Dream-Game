extends Node

var paused = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		paused = !paused
