extends Node2D

var current_biome = "tidepool"

var current_palette = [Color("190111"), Color("f9b3d1"), Color("f1e8b8"), Color("c62e65")]

onready var player = get_parent().get_node("player")
onready var levelManager = get_parent().get_node("levelManager")
onready var cursor = get_parent().get_node("cursor")

var colors = false

func set_background_color(p):
	VisualServer.set_default_clear_color(p[0])

func establish_palette():
	OrganismUtilities.recolor(player, current_palette, player.body_sprite, player.neutral_sprites, player.tail, player.fangs)
	cursor.recolor(current_palette)
	levelManager.recolor(current_palette)
	set_background_color(current_palette)

func _process(delta):
	if !colors:
		establish_palette()
		colors = true
