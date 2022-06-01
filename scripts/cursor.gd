extends Node2D

onready var player = get_parent().get_node("player")
onready var sprite = get_node("sprite")
var mouse_visible = false

var images = [preload("res://sprites/16Finger.png"), preload("res://sprites/16Arrow.png")]
var angling = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func recolor(p):
	sprite.modulate = p[2]

func _process(delta):
	self.global_position = get_global_mouse_position()
	
	if angling:
		var angle_vec = self.global_position - player.global_position
		sprite.rotation = angle_vec.angle()
	
	if Input.is_action_just_pressed("esc"):
		if mouse_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_visible = !mouse_visible

func change_cursor(idx):
	sprite.texture = images[idx]
	if idx == 1:
		angling = true
	if idx == 0:
		angling = false
		sprite.rotation = 0
