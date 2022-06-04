extends Organism

func _ready():
	type = 'player'
	DNA = "atgcatgc"

func _once():
	make_from_genome(DNA)

func _process(delta):
	if !Global.paused:
		if !once:
			_once()
			once = true
		update()

		scaleInfo = OrganismUtilities.handle_scaling(self, scaleInfo, body_sprite, tail, delta)

func _physics_process(delta):
	if !Global.paused:
		var mousePosition = get_global_mouse_position() - self.global_position
		
		linear_velocity = OrganismUtilities.move_toward_target(self, mousePosition, linear_velocity, accel, turnAccel, friction, delta)
		OrganismUtilities.handle_tail(self, tail, linear_velocity, 0.13, 8, 0.85, Ttime, delta)
		OrganismUtilities.handle_whiskers(self, whiskers, 20, delta)
		
		Ttime += delta

func _draw():
	OrganismUtilities.draw_all(self, whiskers)


