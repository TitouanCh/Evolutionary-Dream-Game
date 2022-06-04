extends AnimatedSprite

onready var player = get_parent().get_node("player")
onready var cursor = get_parent().get_node("cursor")
onready var DNAmenu = get_parent().get_node("DNAmenu")

var current_value = 0
var increment = 32
var transitioned = false

func _process(delta):
	self.position = player.position + Vector2(0, 378)
	var b = 1
	if player.belly == 0:
		b = 4
	current_value = lerp(current_value, player.belly, delta * b)
	self.playing = !Global.paused
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

func reset():
	self.animation = "regular"
	transitioned = false

func _on_evolve_text_animation_finished():
	if self.animation == "transition":
		self.animation = "complete"
		self.playing = true

func _on_evolve_button_mouse_entered():
	if (self.animation == "complete" or self.animation == "transition") and !Global.paused:
		cursor.change_cursor(0)

func _on_evolve_button_mouse_exited():
	if !Global.paused:
		cursor.change_cursor(1)

func _on_evolve_button_pressed():
	if true: #self.animation == "complete" or self.animation == "transition":
		DNAmenu.choose_upgrade()
