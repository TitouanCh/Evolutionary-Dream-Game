extends Node2D

onready var cursor = $cursor
onready var DNAmenu = $DNAmenu
onready var evolve_text = $evolve_text

onready var levelManager = get_parent().get_node("levelManager")
onready var player = levelManager.player

func _ready():
	for child in get_children():
		if child.get("player"):
			child.player = player
			print(player)
		if child.get("levelManager"):
			child.levelManager = levelManager
