extends Reference

class_name OrganismUtilities

# DNA Functions ---
static func execute_gene(this, execute_info):
	DataUtilities.execute_file_on(this, execute_info, "OrganismUtilities")

static func read_gene(dna, gene):
	var a = len(gene)
	for i in range(len(dna) - a + 1):
		var possible_gene = ""
		for j in range(a):
			possible_gene += dna[i + j]
		if possible_gene == gene:
			return true
	return false

static func count_gene(dna, gene):
	var a = len(gene)
	var count = 0
	for i in range(len(dna) - a + 1):
		var possible_gene = ""
		for j in range(a):
			possible_gene += dna[i + j]
		if possible_gene == gene:
			count += 1
	return count

# Create Function --- Basic
static func create_rect(dimensions):
	var rect = RectangleShape2D.new()
	rect.set_extents(dimensions)
	return rect

static func create_capsule(dimensions):
	var a = CapsuleShape2D.new()
	a.radius = dimensions.x
	a.height = dimensions.y
	return a

static func create_circle(radius):
	var a = CircleShape2D.new()
	a.radius = radius
	return a

static func create_neutral_sprite(this, text, position):
	var a
	
	# Regular Sprite
	if text is StreamTexture:
		a = Sprite.new()
		a.texture = text
	
	# Animated Sprite
	if text is SpriteFrames:
		a = AnimatedSprite.new()
		a.frames = text
		a.playing = true
		
	this.add_child(a)
	this.neutral_sprites.append(a)
	a.position = position
	a.modulate = this.palette[1]

static func change_body(this, text, shape, rot = 0):
	this.body_sprite.texture = text
	this.body_sprite.rotation_degrees = rot
	this.collisionShape.shape = shape

# Create Functions --- Advanced

static func create_tail_obj(this, img, rotateMode):
	var a = Sprite.new()
	a.modulate = this.palette[1]
	this.get_parent().add_child(a)
	a.texture = img
	
	this.tail.append([a, [Vector2.ZERO, rotateMode]])

static func create_whisker(this, length, anchor, polyX, polyY):
	var points = []
	var velocities = []
	for i in range(length):
		points.append(Vector2.ZERO)
		velocities.append(Vector2.ZERO)
	
	this.whiskers.append([points, velocities, 0, anchor, polyX, polyY])

static func create_fang(this, img, position, arr = [false, false]):
	var a = Sprite.new()
	a.modulate = this.palette[3]
	this.add_child(a)
	a.position = position
	a.texture = img
	
	a.flip_h = arr[0]
	a.flip_v = arr[1]
	
	this.fangs.append(a)

static func create_circ_membrane(this, r, number_of_points):
	this.body_sprite.visible = false
	this.membrane = AdvMath.make_circle(r, number_of_points, this.position)

static func create_jelly(this, text, position):
	var a
	
	# Regular Sprite
	if text is StreamTexture:
		a = Sprite.new()
		a.texture = text
	
	# Animated Sprite
	if text is SpriteFrames:
		a = AnimatedSprite.new()
		a.frames = text
		a.playing = true
		
	this.add_child(a)
	a.position = position
	a.modulate = this.palette[1]
	
	# ACTUAL, TARGET
	this.jellies.append([a, position + this.position, position])

static func change_fang_texture(this, img, idx):
	this.fangs[idx].texture = img

static func create_hurtzone(this, shape, position):
	var a = Area2D.new()
	this.add_child(a)
	var b = CollisionShape2D.new()
	a.add_child(b)
	
	b.shape = shape
	a.position = position
	
	a.connect("body_entered", this, "deal_damage")
	this.hurt_zones.append(a)

# Handle Functions ---

static func handle_tail(this, tail_list, direction_vector, first_space, reaction_speed, tail_force, total_delta, delta):
	for i in range(len(tail_list)):
		# Movement, velocity ---
		var dir = (this.position - (direction_vector * first_space)) - tail_list[i][0].position
		if i > 0:
			dir = tail_list[i-1][0].position - tail_list[i][0].position
		tail_list[i][1][0] += (dir * (i + 1) * reaction_speed) * delta
		var friction = tail_force / (i + 1)
		if i == 1:
			friction = friction - (friction * first_space)
		tail_list[i][1][0] *= friction
		
		# Wiggle ---
		tail_list[i][0].position += tail_list[i][1][0] + Vector2(0, cos((i + total_delta)*5)*2).rotated(this.rotation)
		
		# Rotation ---
		if tail_list[i][1][1] == 1:
			tail_list[i][0].rotation = lerp_angle(tail_list[i][0].rotation, tail_list[i][1][0].angle(), delta * this.turn_accel)
		if tail_list[i][1][1] == 2:
			tail_list[i][0].rotation = lerp_angle(tail_list[i][0].rotation, this.fang_Ttime, delta * this.turn_accel * 5)

static func handle_whiskers(this, whisker_list, whisker_force, delta):
	for i in range(len(whisker_list)):
		# Movement, velocity ---
		for j in len(whisker_list[i][0]):
			if j == 0:
				whisker_list[i][0][j] = this.position + whisker_list[i][3].rotated(this.rotation)
			else:
				var target = whisker_list[i][0][j-1] + Vector2(AdvMath.calc_poly(whisker_list[i][4], j), AdvMath.calc_poly(whisker_list[i][5], j)).rotated(this.rotation) + whisker_list[i][3].rotated(this.rotation)
				whisker_list[i][0][j] = whisker_list[i][0][j].linear_interpolate(target, delta * whisker_force)

static func handle_fangs(this, fang_list, fang_speed, base_fang_speed, total_delta, delta):
	for i in range(len(fang_list)):
		var a = 1
		var b = i % 2 + 1
		if b == 2:
			a = -1
		fang_list[i].rotation = a * cos(total_delta)/4 + PI/3 * b
	fang_speed = lerp(fang_speed, base_fang_speed, delta * 2)
	return fang_speed

static func handle_membrane(this, delta):
	# TEMPORARY
	var targets = AdvMath.make_circle(20, 40, this.position)

	for i in range(len(this.membrane)):
		this.membrane[i] = this.membrane[i].linear_interpolate(targets[i], delta * (800/this.membrane[i].distance_to(this.position)) )

static func handle_jellies(this, delta):
	for i in range(len(this.jellies)):
		this.jellies[i][1] = this.jellies[i][1].linear_interpolate(this.jellies[i][2].rotated(this.rotation) + this.position, delta * this.jellies[i][1].distance_to(this.position))
		this.jellies[i][0].position = AdvMath.to_local(this, this.jellies[i][1])

static func handle_health(this, set_health, health, delta):
	if abs(set_health) < 0.1:
		this.dead = true
	return lerp(set_health, health, delta)

# Draw Functions ---
static func recolor(this, palette, body_sprite, neutral_sprites, tail_list, fang_list):
	this.palette = palette
	body_sprite.modulate = palette[2]
	for s in neutral_sprites:
		s.modulate = palette[1]
	for t in tail_list:
		t[0].modulate = palette[1]
	for f in fang_list:
		f.modulate = palette[3]

static func draw_all(this, whisker_list, set_health, health):
	draw_whiskers(this, whisker_list)
	draw_membrane(this)
	draw_health(this, set_health, health)

static func draw_whiskers(this, whisker_list):
	for i in range(len(whisker_list)):
		for j in range(len(whisker_list[i][0]) - 1):
			if j == 0:
				this.draw_line(whisker_list[i][3], (whisker_list[i][0][j + 1] - this.position).rotated(-this.rotation), this.palette[1])
			else:
				this.draw_line((whisker_list[i][0][j] - this.position).rotated(-this.rotation), (whisker_list[i][0][j + 1] - this.position).rotated(-this.rotation), this.palette[1])

static func draw_membrane(this):
	if len(this.membrane) > 0:
		for i in range(len(this.membrane) - 1):
			this.draw_line((this.membrane[i] - this.position).rotated(-this.rotation), (this.membrane[i + 1] - this.position).rotated(-this.rotation), this.palette[2])
		this.draw_line((this.membrane[len(this.membrane) - 1] - this.position).rotated(-this.rotation), (this.membrane[0] - this.position).rotated(-this.rotation), this.palette[2])

static func draw_health(this, set_health, health):
	if abs(set_health - health) > 0.1:
		var vec1 = Vector2(-50, -50).rotated(-this.rotation)
		var vec2 = Vector2(set_health - 50, -50).rotated(-this.rotation)
		var vec3 = Vector2(health - 50, -50).rotated(-this.rotation)
		this.draw_line(vec1, vec2, Color("9a4f50"))
		this.draw_line(vec1, vec3, Color("#6eaa78"))

# Movement Function ---

static func move_toward_target(this, target, linear_velocity, accel, turn_accel, friction, delta):
	var angle2target = target.angle()
	
	this.rotation = lerp_angle(this.rotation, angle2target, delta * turn_accel)
	
	linear_velocity += Vector2(cos(this.rotation) * accel, sin(this.rotation) * accel)
	linear_velocity *= friction
	
	this.move_and_slide(linear_velocity, Vector2.ZERO)
	
	return linear_velocity

static func handle_scaling(this, scale_info, body_sprite, tail_list, delta, curve = [1, 3, -12], duration = 0.3):
	var scaleTimer = scale_info[0]
	var scaleIdx = scale_info[1]
	
	if scaleTimer != -1 and scaleIdx == -1:
		scaleTimer = scaling_effect(this, body_sprite, scaleTimer, delta, curve, duration)
		
		if scaleTimer == -1 and len(tail_list) > scaleIdx + 1:
			scaleIdx += 1
			scaleTimer = 0
	
	if scaleIdx >= 0:
		scaleTimer = scaling_effect(this, tail_list[scaleIdx][0], scaleTimer, delta, curve, duration)

		if scaleTimer == -1 and len(tail_list) > scaleIdx + 1:
			scaleIdx += 1
			scaleTimer = 0
		elif scaleTimer == -1:
			scaleIdx = -1
			scaleTimer = -1
	
	return [scaleTimer, scaleIdx]

static func scaling_effect(this, body_sprite, scale_timer, delta, curve = [1, 3, -12], duration = 0.3):
	if scale_timer >= 0:
		var curr = AdvMath.calc_poly(curve, scale_timer)
		if curr > 1:
			body_sprite.scale = Vector2.ONE * curr
		else:
			body_sprite.scale = Vector2.ONE
		if scale_timer > duration:
			return -1
		return scale_timer + delta
	return -1

static func organism_check(obj):
	# Needs improvements
	return obj.get_class() == "KinematicBody2D"
