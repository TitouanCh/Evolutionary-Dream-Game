extends Node2D

onready var pixel = $pixelMultimesh
onready var levelManager = get_parent().get_node("levelManager")

var debris = {}
var friction = 0.98

func create_rigid_body(coord, rot, text, shape, spr_rot = 0):
	var a = RigidBody2D.new()
	self.add_child(a)
	a.gravity_scale = 0
	a.position = coord
	
	var b = Sprite.new()
	a.add_child(b)
	b.texture = text
	b.rotation = spr_rot
	
	var c = CollisionShape2D.new()
	a.add_child(c)
	c.rotation_degrees = 90
	c.shape = shape
	
	a.rotation = rot

func create_debris_rect(coord, velocity, dimensions):
	for i in range(0, dimensions.x):
		for j in range(0, dimensions.y):
			debris[len(debris)] = [coord + Vector2(i, j), velocity/3]

func create_debris_circ(coord, velocity, r):
	for i in AdvMath.sunflower(100, 2):
		debris[len(debris)] = [i*r + coord, velocity/3]
		debris[len(debris) - 1][1] += impulse(coord, debris[len(debris) - 1][0])

func impulse(origin, coord):
	return (coord - origin).normalized() * 10

func handle_draw_debris(debris, delta):
	for key in debris:
		debris[key][0] += Vector2(randf() - 0.5, randf() - 0.5) + debris[key][1] * delta
		debris[key][1] *= friction
		
		# Probably temporary
		for entity in levelManager.instance_annuaire["organism"] + [[levelManager.player, true]]:
			if entity[0].position.distance_to(debris[key][0]) < 10:
				debris[key][1] += impulse(entity[0].position, debris[key][0])
		
		# Draw
		if key < pixel.multimesh.instance_count:
			var t = Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)).translated(debris[key][0])
			pixel.multimesh.set_instance_transform_2d(key, t)

func _process(delta):
	handle_draw_debris(debris, delta)

func _ready():
#	$Sprite.transform = Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(0, 0))
#	for i in range(multimesh.multimesh.instance_count):
#		multimesh.multimesh.set_instance_transform_2d(i, Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(50 * i, 1)))
	pass
