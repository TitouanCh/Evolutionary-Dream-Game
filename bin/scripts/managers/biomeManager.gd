extends Node2D

var current_biome = "tidepool"

var current_palette = [Color("190111"), Color("f9b3d1"), Color("f1e8b8"), Color("c62e65")]

onready var player = get_parent().get_node("levelManager").get_node("player")
onready var levelManager = get_parent().get_node("levelManager")
onready var UIManager = get_parent().get_node("UIManager")
onready var background = get_node("background")

var colors = false

func set_background_color(p):
	background.modulate = p[0]

func establish_palette():
	OrganismUtilities.recolor(player, current_palette, player.body_sprite, player.neutral_sprites, player.tail, player.fangs)
	UIManager.cursor.recolor(current_palette)
	levelManager.recolor(current_palette)
	set_background_color(current_palette)

func _process(delta):
	if !colors:
		establish_palette()
		colors = true
