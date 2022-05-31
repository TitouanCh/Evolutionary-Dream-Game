extends RigidBody2D

var turnAccel = 20
var accel = 20
var maxVelocity = 100

func _physics_process(delta):
	var mousePosition = get_local_mouse_position() - $camera.position
	var angle2mouse = mousePosition.angle()
	var angle2mouseDelta = abs(mousePosition.angle() - self.rotation)
	
	var moveVector = Vector2(cos(rotation) * accel, sin(rotation) * accel)
	if (moveVector.x > 0 and self.linear_velocity.x > maxVelocity) or (moveVector.x < 0 and self.linear_velocity.x < -maxVelocity):
		moveVector.x = 0
	if (moveVector.y > 0 and self.linear_velocity.y > maxVelocity) or (moveVector.y < 0 and self.linear_velocity.y < -maxVelocity):
		moveVector.y = 0
	self.apply_impulse(Vector2.ZERO, moveVector * delta * (-abs(angle2mouse) + 3.14))
	
	var turnVector = turnAccel
	
	if angle2mouse > 0:
		turnVector *= turnAccel
		if self.angular_velocity > 0:
			turnVector * pow(angle2mouseDelta, 2)
	if angle2mouse < 0:
		turnVector *= -turnAccel
		if self.angular_velocity < 0:
			turnVector * pow(angle2mouseDelta, 2)
	
	self.apply_torque_impulse(turnVector * delta)
	
	print(get_local_mouse_position())

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		maxVelocity = 500
		accel = 100
	if Input.is_action_just_released("left_click"):
		maxVelocity = 100
		accel = 20
