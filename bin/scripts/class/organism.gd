extends KinematicBody2D

class_name Organism

var DNA = "agc"

var turnAccel = 10
var accel = 10
var friction = 0.95
var once = false

var health = 100
var dead = false
var set_health = health
var armor = 0
var attack = 10

var soundmanager

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

# fang object format : [Sprite]
var fang_speed = 1
var fang_Ttime = 0
var base_fang_speed = 1
var fangs = []

# hurt zones
var hurt_zones = []

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

	for f in fangs:
		f.queue_free()
	fangs = []
	
	for h in hurt_zones:
		h.queue_free()
	hurt_zones = []
	
	turnAccel = 0
	accel = 0
	friction = 0.95
	scaleInfo = [-1, -1]
	health = 100
	set_health = 100
	attack = 10
	dead = false

func deal_damage(body):
	fang_speed += 40
	if body != self:
		body.knock(position, 4 + linear_velocity.length() / 25)
		body.take_damage(attack)

func take_damage(amount):
	health -= amount - amount * (-(1 / (armor / 20 + 1)) + 1)
	if health < 0:
		health = 0

func knock(from, force):
	soundmanager.play_knock()
	linear_velocity += (self.position - from) * force

func make_from_genome(dna):
	reset()
	
	# Strong tail gene : tcc
	for i in range(OrganismUtilities.count_gene(dna, "tcc")):
		OrganismUtilities.create_tail_obj(self, tail, load("res://assets/sprites/24Circle.png"), 0)
		accel += 1
	
	# Armored tail gene : cct
	for i in range(OrganismUtilities.count_gene(dna, "cct")):
		OrganismUtilities.create_tail_obj(self, tail, load("res://assets/sprites/24Square.png"), 2)
		armor += 5
		accel += 0.1
	
	# Teeth I : atgca
	if OrganismUtilities.read_gene(dna, "atgca"):
		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/16SmallFang.png"), Vector2(16, -8), [false, false])
		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/16SmallFang.png"), Vector2(16, 8), [true, false])
		var a = CapsuleShape2D.new()
		a.radius = 4
		a.height = 20
		OrganismUtilities.create_hurtzone(self, hurt_zones, Vector2(18, 0), a)
	
	# Teeth II : aaatt
	if OrganismUtilities.read_gene(dna, "aaatt"):
		fangs[0].texture = load("res://assets/sprites/16Fang.png")
		fangs[1].texture = load("res://assets/sprites/16Fang.png")
		attack += 20
	
	# Teeth III : tatatt
	if OrganismUtilities.read_gene(dna, "tatatt"):
		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/32Fang.png"), Vector2(16, -14), [false, false])
		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/32Fang.png"), Vector2(16, 14), [true, false])
		attack += 20
	
	
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
		body_sprite.texture = load("res://assets/sprites/heavySquare.png")
		var rect = RectangleShape2D.new()
		rect.set_extents(Vector2(16, 16))
		collisionShape.shape = rect
		
		#Shrimp tail
		for i in range(2):
			OrganismUtilities.create_tail_obj(self, tail, load("res://assets/sprites/24Circle.png"), 0)
		OrganismUtilities.create_tail_obj(self, tail, load("res://assets/sprites/24Demi.png"), 1)
		
		# Caracteristics
		turnAccel += 8
		accel += 10
	
	
	# Bacteria gene : agccgtt
	if OrganismUtilities.read_gene(dna, "agccgtt"):
		# Wireframe body
		body_sprite.texture = load("res://assets/sprites/cell_wireframe.png")
		var cap = CapsuleShape2D.new()
		cap.radius = 13
		cap.height = 28
		collisionShape.shape = cap
		
		# Flagellum
		var a = AnimatedSprite.new()
		self.add_child(a)
		a.modulate = palette[1]
		a.frames = load("res://assets/sprites/flagellum1/flagellum.tres")
		a.playing = true
		a.position = Vector2(-32, 0)
		neutral_sprites.append(a)
		
		# Caracteristics
		type = 'herbivore'
		turnAccel += 1
		accel += 3
