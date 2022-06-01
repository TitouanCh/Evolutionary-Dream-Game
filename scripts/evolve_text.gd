extends AnimatedSprite

onready var player = get_parent().get_node("player")
onready var cursor = get_parent().get_node("cursor")

var current_value = 0
var increment = 32
var transitioned = false

func _process(delta):
	self.position = player.position + Vector2(0, 378)
	current_value = lerp(current_value, player.belly, delta)
	update()

func _draw():
	if current_value > 0:
		var y = current_value * increment
		if y > 300:
			y = 300
			if !transitioned:
				self.animation = "transition"
				self.playing = true
				transitioned = true
		draw_rect(Rect2(-150, 4, y, 24), Color("#FFFF"))

func _on_evolve_text_animation_finished():
	if self.animation == "transition":
		self.animation = "complete"
		self.playing = true


func _on_evolve_button_mouse_entered():
	if self.animation == "complete" or self.animation == "transition":
		cursor.change_cursor(0)

func _on_evolve_button_mouse_exited():
	cursor.change_cursor(1)
