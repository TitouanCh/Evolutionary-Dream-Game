extends KinematicBody2D

class_name Organism

var DNA = "agc"

var turnAccel = 10
var accel = 10
var friction = 0.95
var once = false

var belly = 0

var type

var scaleInfo = [-1, -1]

onready var body_sprite = $sprite
var neutral_sprites = []
var palette = [Color(255), Color(255), Color(255), Color(255)]

onready var collisionShape = $collisionShape

var Ttime = 0

var linear_velocity = Vector2.ZERO

var active = true

# tail object format : [Sprite : Node, [Velocity : Vector2, rotateMode : int]]
var tail = []

# whisker object format : [[points], [Velocities], function]
var whiskers = []

func set_active(state):
	active = state
	self.visible = state
	collisionShape.disabled = !state

func reset():
	for t in tail:
		t[0].queue_free()
	tail = []
	whiskers = []
	
	for s in neutral_sprites:
		s.queue_free()
	neutral_sprites = []
	belly = 0
	
	turnAccel = 0
	accel = 0
	friction = 0.95

func make_from_genome(dna):
	reset()
	
	# Strong tail gene : tcc
	for i in range(OrganismUtilities.count_gene(dna, "tcc")):
		OrganismUtilities.create_tail_obj(self, tail, load("res://sprites/24Circle.png"), 0)
		accel += 1
	
	# Whisker gene I : gcggg
	if OrganismUtilities.read_gene(dna, "gcggg"):
		OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(10, 16), [15, 0, 1.4], [1, 0, -1])
		OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(10, -16), [15, 0, 1.4], [-1, 0, 1])
		turnAccel += 2.5
	
	# Whisker gene II : gcgttt
	if OrganismUtilities.read_gene(dna, "gcgttt"):
		OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(0, 16), [15, 0, 1.4], [1, 0, -1])
		OrganismUtilities.create_whisker(self, whiskers, 3, Vector2(0, -16), [15, 0, 1.4], [-1, 0, 1])
		turnAccel += 2.5
	
	# Whisker gene III : gcatgg
	if OrganismUtilities.read_gene(dna, "gcatgg"):
		OrganismUtilities.create_whisker(self, whiskers, 4, Vector2(-5, 16), [0, -4, 2], [1, 0, -1])
		OrganismUtilities.create_whisker(self, whiskers, 4, Vector2(-5, -16), [0, -4, 2], [-1, 0, 1])
		OrganismUtilities.create_whisker(self, whiskers, 4, Vector2(-10, 16), [0, -4, 2], [1, 0, -1])
		OrganismUtilities.create_whisker(self, whiskers, 4, Vector2(-10, -16), [0, -4, 2], [-1, 0, 1])
		turnAccel += 3.5
	
	# Shrimp gene : atgcatgc
	if OrganismUtilities.read_gene(dna, "atgcatgc"):
		# Crusty body
		body_sprite.texture = load("res://sprites/heavySquare.png")
		var rect = RectangleShape2D.new()
		rect.set_extents(Vector2(16, 16))
		collisionShape.shape = rect
		
		#Shrimp tail
		for i in range(2):
			OrganismUtilities.create_tail_obj(self, tail, load("res://sprites/24Circle.png"), 0)
		OrganismUtilities.create_tail_obj(self, tail, load("res://sprites/24Demi.png"), 1)
		
		# Caracteristics
		turnAccel += 8
		accel += 10
	
	
	# Bacteria gene : agccgtt
	if OrganismUtilities.read_gene(dna, "agccgtt"):
		# Wireframe body
		body_sprite.texture = load("res://sprites/cell_wireframe.png")
		var cap = CapsuleShape2D.new()
		cap.radius = 13
		cap.height = 28
		collisionShape.shape = cap
		
		# Flagellum
		var a = AnimatedSprite.new()
		self.add_child(a)
		a.frames = load("res://sprites/flagellum1/flagellum.tres")
		a.playing = true
		a.position = Vector2(-32, 0)
		neutral_sprites.append(a)
		
		# Caracteristics
		type = 'herbivore'
		turnAccel += 1
		accel += 3
