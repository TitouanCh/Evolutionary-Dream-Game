extends Organism

var target = Vector2.ZERO

func _ready():
	type = 'herbivore'
	neutral_sprites.append($flagel)
	turnAccel = 3
	accel = 3

func _process(delta):
	if active:
		scaleInfo = OrganismUtilities.handle_scaling(self, scaleInfo, body_sprite, tail, delta)

func _physics_process(delta):
	if active:
		var relative_target = target - self.global_position
		
		linear_velocity = OrganismUtilities.move_toward_target(self, relative_target, linear_velocity, accel, turnAccel, friction, delta)
