extends Node2D

onready var player = get_parent().get_node("levelManager").get_node("player")
onready var cursor = get_parent().get_node("cursor")
onready var evolve_text = get_parent().get_node("evolve_text")
onready var levelManager = get_parent().get_node("levelManager")

onready var upgrades = [$upgrade1, $upgrade2, $upgrade3]
onready var dnaline = $DNALine

func _process(delta):
	self.position = player.position
	dnaline.bbcode_text = player.DNA
	update()

func _draw():
	draw_line(Vector2(-512, -303), Vector2(512, -303), Color(255, 255, 255))
	draw_line(Vector2(-512, -279), Vector2(512, -280), Color(255, 255, 255))

func choose_upgrade():
	self.visible = true
	Global.paused = true
	cursor.change_cursor(0)

	for u in upgrades:
		randomize()
		u.set_random_upgrade()
		u.visible = true

func upgrade_player(dna):
	player.DNA += dna
	player.make_from_genome(player.DNA)
	for u in upgrades:
		u.visible = false
	
	yield(get_tree().create_timer(1), "timeout")
	Global.paused = false
	self.visible = false
	cursor.change_cursor(1)
	evolve_text.reset()
	
	levelManager.progress(1)
