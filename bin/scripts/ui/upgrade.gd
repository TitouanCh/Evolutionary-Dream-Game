extends Node2D

var size = Vector2(216, 216)
onready var title = $title
onready var description = $description

var ni = 0

func _draw():
	# Right border
	draw_line(Vector2(-size.x/2, size.y/2), Vector2(-size.x/2, -size.y/2), Color(255, 255, 255))
	
	# Left border
	draw_line(Vector2(size.x/2, size.y/2), Vector2(size.x/2, -size.y/2), Color(255, 255, 255))
	
	# Top border
	draw_line(Vector2(size.x/2 - 1, -size.y/2), Vector2(-size.x/2 + 1, -size.y/2), Color(255, 255, 255))

func set_random_upgrade():
	ni = randi() % len(UpgradeEther.upgrade_title)
	while UpgradeEther.idx_is_locked(ni, UpgradeEther.upgrade_meta):
		ni = randi() % len(UpgradeEther.upgrade_title)
	title.bbcode_text = "[center]" + UpgradeEther.upgrade_title[ni] + "[/center]"
	description.bbcode_text = "[center]" + UpgradeEther.upgrade_description[ni] + "\n" + UpgradeEther.upgrade_dna[ni] + "[/center]"

func _on_button_pressed():
	UpgradeEther.update_lists(ni)
	get_parent().upgrade_player(UpgradeEther.upgrade_dna[ni])
