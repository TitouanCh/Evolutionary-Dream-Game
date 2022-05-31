extends Organism

func _ready():
	type = 'player'

func _once():
	for i in range(3):
		OrganismUtilities.create_tail_obj(self, tail, load("res://sprites/24Circle.png"), 0)
	OrganismUtilities.create_tail_obj(self, tail, load("res://sprites/24Demi.png"), 1)
	
	OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(10, 16), [15, 0, 1.4], [1, 0, -1])
	OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(10, -16), [15, 0, 1.4], [-1, 0, 1])
	OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(0, 16), [15, 0, 1.4], [1, 0, -1])
	OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(0, -16), [15, 0, 1.4], [-1, 0, 1])

func _process(delta):
	if !once:
		_once()
		once = true
	update()
	
	scaleInfo = OrganismUtilities.handle_scaling(self, scaleInfo, body_sprite, tail, delta)

func _physics_process(delta):
	var mousePosition = get_global_mouse_position() - self.global_position
	
	linear_velocity = OrganismUtilities.move_toward_target(self, mousePosition, linear_velocity, accel, turnAccel, friction, delta)
	OrganismUtilities.handle_tail(self, tail, linear_velocity, 0.13, 8, 0.85, Ttime, delta)
	OrganismUtilities.handle_whiskers(self, whiskers, 20, delta)
	
	Ttime += delta

func _draw():
	OrganismUtilities.draw_all(self, whiskers)


