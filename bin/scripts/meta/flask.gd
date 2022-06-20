extends Node2D

onready var ether = get_node("viewportContainer/ether")

func _ready():
	ether.size = get_viewport().size

func _process(delta):
	ether.size = OS.get_window_size()
