extends KinematicBody2D

class_name Organism

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Basic Data

# - Meta data
var DNA = "agc"
export var behavior = "none"

# - Movement
var turnAccel = 10
var accel = 10
var friction = 0.95
var linear_velocity = Vector2.ZERO
var target = Vector2.ZERO

# - Durability
var health = 100
var set_health = health
var armor = 0
var attack = 10

var belly = 0

# - Absolute booleans
# once : called once on creation to spawn stuff
var once = false
var dead = false
# active : used by non-player characters, to deactivate oob entities
var active = true

# - Pointers/runtime stuff
var soundmanager
onready var body_sprite = $sprite
onready var collisionShape = $collisionShape
var levelmanager
var neutral_sprites = []
var palette = [Color(255), Color(255), Color(255), Color(255)]

# - Graphics
var scaleInfo = [-1, -1]

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Organism Characteristics

# - Tail
# tail object format : [Sprite : Node, [Velocity : Vector2, rotateMode : int]]
var tail = []
var tail_Ttime = 0

# - Whiskers
# whisker object format : [[points], [Velocities], function]
var whiskers = []

# - Fangs
# fang object format : [Sprite]
var fang_speed = 1
var fang_Ttime = 0
var base_fang_speed = 1
var fangs = []

# - Hurt Zones
var hurt_zones = []

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Basic/Essential Functions

# - Setup
# pass important variables
func setup(dna, b, lm, sm):
	behavior = b
	DNA = dna
	levelmanager = lm
	soundmanager = sm

func _once():
	make_from_genome(DNA)

# - Set Active
func set_active(state):
	active = state
	self.visible = state
	collisionShape.disabled = !state

# - Reset
func reset():
	# reset tail
	for t in tail:
		t[0].queue_free()
	tail = []
	whiskers = []
	
	# reset neutral sprites
	for s in neutral_sprites:
		s.queue_free()
	neutral_sprites = []
	belly = 0

	# reset fangs
	for f in fangs:
		f.queue_free()
	fangs = []
	
	# reset hurt zones
	for h in hurt_zones:
		h.queue_free()
	hurt_zones = []
	
	# reset stats
	turnAccel = 0
	accel = 0
	friction = 0.95
	scaleInfo = [-1, -1]
	health = 100
	set_health = 100
	attack = 10
	dead = false

# - Deal Damage
# deal damage to another organism
func deal_damage(body):
	fang_speed += 40
	if body != self:
		body.knock(position, 4 + linear_velocity.length() / 25)
		body.take_damage(attack)

# - Take Damage
func take_damage(amount):
	health -= amount - amount * (-(1 / (armor / 20 + 1)) + 1)
	if health < 0:
		health = 0

# - Knockback
# get knocked from a point
func knock(from, force):
	soundmanager.play_sound("knock")
	linear_velocity += (self.position - from) * force

# - Make the organism from the genome, using data (WIP)...
func make_from_genome(dna):
	reset()
	
	for gene in Global.geneDatabase:
		if Global.geneDatabase[gene].has("COUNT"):
			for i in range(OrganismUtilities.count_gene(dna, gene)):
				OrganismUtilities.execute_gene(self, Global.geneDatabase[gene])
		else:
			if OrganismUtilities.read_gene(dna, gene):
				OrganismUtilities.execute_gene(self, Global.geneDatabase[gene])
	
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
#	if OrganismUtilities.read_gene(dna, "atgca"):
#		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/16SmallFang.png"), Vector2(16, -8), [false, false])
#		OrganismUtilities.create_fang(self, fangs, load("res://assets/sprites/16SmallFang.png"), Vector2(16, 8), [true, false])
#		var a = CapsuleShape2D.new()
#		a.radius = 4
#		a.height = 20
#		OrganismUtilities.create_hurtzone(self, hurt_zones, Vector2(18, 0), a)
	
	# Teeth II : aaatt
#	if OrganismUtilities.read_gene(dna, "aaatt"):
#		fangs[0].texture = load("res://assets/sprites/16Fang.png")
#		fangs[1].texture = load("res://assets/sprites/16Fang.png")
#		attack += 20
	
	# Teeth III : tatatt
#	if OrganismUtilities.read_gene(dna, "tatatt"):
#		OrganismUtilities.create_fang(self, load("res://assets/sprites/32Fang.png"), Vector2(16, -14), [false, false])
#		OrganismUtilities.create_fang(self, load("res://assets/sprites/32Fang.png"), Vector2(16, 14), [true, false])
#		attack += 20
	
	
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
		body_sprite.rotation_degrees = 0
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
		behavior = 'herbivore'
		turnAccel += 1
		accel += 3

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Update Functions

# - Process
func _process(delta):
	
	if !Global.paused:
		
		# . player behavior
		if behavior == "player":
			if Input.is_action_just_pressed("left_click") and !once:
				$title.queue_free()
				$description.queue_free()
			if set_health < 1:
				get_tree().reload_current_scene()
		# ..

		scaleInfo = OrganismUtilities.handle_scaling(self, scaleInfo, body_sprite, tail, delta)
	
		if !once and (behavior != "player" or Input.is_action_just_pressed("left_click")):
			_once()
			once = true
		
		update()

# - Physics Process
func _physics_process(delta):
	
	if !Global.paused and once:
		
		# . player behavior
		if behavior == "player":
			target = get_global_mouse_position() - self.global_position
			if !once:
				position.x += 32 * delta
		# ..
		
		# . herbivore behavior
		if behavior == "herbivore":
			target = target - self.global_position
		# ..
		
		OrganismUtilities.handle_tail(self, tail, linear_velocity, 0.13, 8, 0.85, tail_Ttime, delta)
		tail_Ttime += delta
		
		OrganismUtilities.handle_whiskers(self, whiskers, 20, delta)
		
		fang_speed = OrganismUtilities.handle_fangs(self, fangs, fang_speed, base_fang_speed, fang_Ttime, delta)
		fang_Ttime += delta * fang_speed
		
		set_health = OrganismUtilities.handle_health(self, set_health, health, delta)
		
		linear_velocity = OrganismUtilities.move_toward_target(self, target, linear_velocity, accel, turnAccel, friction, delta)

func _draw():
	OrganismUtilities.draw_all(self, whiskers, set_health, health)
