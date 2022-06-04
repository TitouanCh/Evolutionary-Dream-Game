extends Organism

var target = Vector2.ZERO

func _ready():
	DNA = "agccgtt"

func _once():
	make_from_genome(DNA)

func _process(delta):
	if !once:
		_once()
		once = true
	
	if !Global.paused:
		if active:
			scaleInfo = OrganismUtilities.handle_scaling(self, scaleInfo, body_sprite, tail, delta)

func _physics_process(delta):
	if !Global.paused:
		if active:
			var relative_target = target - self.global_position
			
			linear_velocity = OrganismUtilities.move_toward_target(self, relative_target, linear_velocity, accel, turnAccel, friction, delta)
