extends Node2D

onready var player = get_parent().get_node("player")

var once = false

var food = []
var foodSprites = [0]
var foodText = preload("res://sprites/16Circle.png")

var debris = []
var debrisSprites = [0]
var debrisText = preload("res://sprites/1Pixel.png")

var palette = [Color(255), Color(255), Color(255), Color(255)]

var explosionSystems = [0]
var explosionScene = preload("res://scenes/explosionParticleSystem.tscn")

# npc format, [position, dna, behavior, loaded]
var npc = []
var npcInstances = [0]
var npcScene = preload("res://scenes/npc.tscn")

var currents = []
var currents_resolution = 64
var current_force = 40
var depth = 0

var big_distance = 524288
var small_distance = 512

func _ready():
	currents = make_currents(512)

func _once():
	setup_food_sprites(64, foodText)
	setup_debris_sprites(128, debrisText)
	setup_explosion_systems(8)
	setup_npcs(8)
	
	spawn_food_randomly(600, food, Vector2(0, 16384), Vector2(0, 16384))
	spawn_npcs_randomly(100, npc, Vector2(0, 16384), Vector2(0, 16384), "agccgtt")
	spawn_npcs_randomly(10, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")
	
	spawn_debris(420, debris, Vector2(0, 200), Vector2(0, 200))

func progress(n):
	depth += n
	if depth == 1:
		spawn_npcs_randomly(100, npc, Vector2(0, 16384), Vector2(0, 16384), "agccgtt")
		spawn_npcs_randomly(10, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")
	if depth == 3:
		spawn_food_randomly(600, food, Vector2(0, 16384), Vector2(0, 16384))
	if depth == 4:
		spawn_npcs_randomly(60, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")

func _process(delta):
	if !Global.paused:
		if !once:
			_once()
			once = true
		handle_food(delta, food)
		handle_npc(delta, npc, food)
		handle_debris(delta, debris)
		
		player.linear_velocity += get_current(currents, currents_resolution, player.position) * current_force * delta
		update()

func setup_food_sprites(n, text):
	for i in range(n):
		var a = Sprite.new()
		self.add_child(a)
		a.texture = text
		a.visible = false
		foodSprites.append(a)
		a.modulate = palette[1]

func setup_debris_sprites(n, text):
	for i in range(n):
		var a = Sprite.new()
		self.add_child(a)
		a.texture = text
		a.visible = false
		debrisSprites.append(a)
		a.modulate = palette[2]

func setup_explosion_systems(n):
	for i in range(n):
		var a = explosionScene.instance()
		self.add_child(a)
		explosionSystems.append(a)
		a.modulate = palette[2]

func setup_npcs(n):
	for i in range(n):
		var a = npcScene.instance()
		self.add_child(a)
		npcInstances.append(a)
		a.set_active(false)
		OrganismUtilities.recolor(a, palette, a.body_sprite, a.neutral_sprites, a.tail, a.fangs)

func handle_food(d, f):
	var idx_remove_list = []
	for i in range(len(f)):
		f[i] += get_current(currents, currents_resolution, f[i]) * current_force * d
		for w in range(len(npcInstances)):
			var entity = player
			if w > 0:
				entity = npcInstances[w]
			var distance = f[i].distance_squared_to(entity.position)
			if  distance < big_distance:
				foodSprites[foodSprites[0] + 1].visible = true
				foodSprites[foodSprites[0] + 1].position = f[i]
				foodSprites[0] += 1
				if foodSprites[0] == len(foodSprites) - 1:
					foodSprites[0] = 0
			if distance < small_distance:
				explosionSystems[explosionSystems[0] + 1].position = f[i]
				explosionSystems[explosionSystems[0] + 1].emitting = true
				explosionSystems[explosionSystems[0] + 1].process_material.set_shader_param("impact", entity.linear_velocity)
				entity.scaleInfo[0] = 0
				for j in range(1, len(foodSprites)):
					if foodSprites[j].position == f[i]:
						foodSprites[j].visible = false
				idx_remove_list.append(i)
				entity.belly += 1
				entity.fang_speed += 40
				explosionSystems[0] += 1
				if explosionSystems[0] == len(explosionSystems) - 1:
					explosionSystems[0] = 0
				break
	
	for i in idx_remove_list:
		f.remove(i)

func handle_debris(d, f):
	for i in range(len(f)):
		
		f[i] += get_current(currents, currents_resolution, f[i]) * current_force * d * 6
		f[i] += Vector2(randf() * 3 - 1.5, randf() * 3 - 1.5)
		
		var distance = f[i].distance_squared_to(player.position)
		
		if  distance < big_distance:
			debrisSprites[debrisSprites[0] + 1].visible = true
			debrisSprites[debrisSprites[0] + 1].position = f[i]
			debrisSprites[0] += 1
			if debrisSprites[0] == len(debrisSprites) - 1:
				debrisSprites[0] = 0
		else:
			f[i] = Vector2(randf() * 4000 - 2000 + player.position.x, randf() * 4000 - 2000 + player.position.y)

func spawn_food_randomly(n, f, xbor, ybor):
	for i in range(n):
		randomize()
		f.append(Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))))

func spawn_food(pos, f):
	f.append(pos)

func spawn_debris(n, f, xbor, ybor):
	for i in range(n):
		randomize()
		f.append(Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))))

func delete_debris(n, f):
	for i in range(n):
		f.remove(0)

func spawn_npcs_randomly(n, f, xbor, ybor, dna):
	for i in range(n):
		randomize()
		f.append([Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))), dna, "b", 0])

func handle_npc(delta, npc, food):
	var idx_remove_list = []
	
	for i in range(len(npc)):
		var distance = npc[i][0].distance_squared_to(player.position)
		if  distance < big_distance and !npc[i][3]:
			for j in range(1, len(npcInstances)):
				if !npcInstances[j].active: npcInstances[0] = j
			npcInstances[npcInstances[0]].DNA = npc[i][1]
			npcInstances[npcInstances[0]]._once()
			npcInstances[npcInstances[0]].position = npc[i][0]
			npcInstances[npcInstances[0]].rotation = randf() * PI * 2
			npcInstances[npcInstances[0]].set_active(true)
			npc[i][3] = npcInstances[0]
		elif npc[i][3]:
			if npcInstances[npc[i][3]].position.distance_squared_to(player.position) > big_distance:
				npc[i][0] = npcInstances[npc[i][3]].position
				npcInstances[npc[i][3]].set_active(false)
				npc[i][3] = 0
			else:
				var closest_food = Vector2.ZERO
				var smallest_distance = big_distance*2*2
				for j in range(len(food)):
					var dist = food[j].distance_squared_to(npcInstances[npc[i][3]].position)
					if dist < smallest_distance:
						closest_food = food[j]
						smallest_distance = dist
				npcInstances[npc[i][3]].target = closest_food
				npcInstances[npc[i][3]].linear_velocity += get_current(currents, currents_resolution, npcInstances[npc[i][3]].position) * current_force * delta
				
				if npcInstances[npc[i][3]].dead:
					idx_remove_list.append(i)
					for w in range(5):
						explosionSystems[explosionSystems[0] + 1].position = npcInstances[npc[i][3]].position
						explosionSystems[explosionSystems[0] + 1].emitting = true
						explosionSystems[explosionSystems[0] + 1].process_material.set_shader_param("impact", npcInstances[npc[i][3]].linear_velocity)
					for z in range(npcInstances[npc[i][3]].belly + 2):
						spawn_food(npcInstances[npc[i][3]].position + Vector2(randf() * 32 - 16, randf() * 64 - 16), food)
					npcInstances[npc[i][3]].set_active(false)
				
		else:
			npc[i][0] += Vector2(randf()-0.5, randf()-0.5) * delta * 10
	
	for i in idx_remove_list:
		npc.remove(i)

func recolor(p):
	palette = p
	for i in range(1, len(foodSprites)):
		foodSprites[i].modulate = p[2]
	for i in range(1, len(debrisSprites)):
		debrisSprites[i].modulate = p[1]
	for i in range(1, len(explosionSystems)):
		explosionSystems[i].modulate = p[2]
	for i in range(1, len(npcInstances)):
		OrganismUtilities.recolor(npcInstances[i], p, npcInstances[i].body_sprite, npcInstances[i].neutral_sprites, npcInstances[i].tail, npcInstances[i].fangs)

func make_currents(size = 10):
	var currents_table = []
	
	for i in range(size):
		var r = []
		for j in range(size):
			r.append(Vector2.ZERO)
		currents_table.append(r)
	
	var noise = OpenSimplexNoise.new()
	
	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	var noise_image = noise.get_image(size, size)
	
	for y in range(size):
		for x in range(size):
			currents_table[y][x].x = noise.get_noise_2d(x, y)
			currents_table[y][x].y = noise.get_noise_3d(x, 0, y)
	
	return currents_table

func get_current(c, r, pos):
	var a2 = int(pos.x) % r + (pos.x - int(pos.x))
	var a1 = r - a2
#
#	var x = c[floor(pos.x/r)].x * a1 + c[ceil(pos.x/r)].x * a2
	
	var b2 = int(pos.y) % r + (pos.y - int(pos.y))
	var b1 = r - b2
	
#	var y = c[floor(pos.y/r)].y * b1 + c[ceil(pos.y/r)].y * b2
	
	var v1 = c[floor(pos.y/r)][floor(pos.x/r)] * (b1 + a1)
	var v2 = c[ceil(pos.y/r)][floor(pos.x/r)] * (b2 + a1)
	var v3 = c[floor(pos.y/r)][ceil(pos.x/r)] * (b1 + a2)
	var v4 = c[ceil(pos.y/r)][ceil(pos.x/r)] * (b2 + a2)
	
	return (v1 + v2 + v3 + v4) / (b1 + b1 + b2 + b2 + a1 + a1 + a2 + a2)

func draw_currents(c, r):
	for y in range(len(currents)):
		for x in range(len(currents[y])):
			if Vector2(x * r, y * r).distance_squared_to(player.position) < 262144:
				draw_line(Vector2(x, y) * r, (Vector2(x, y) + currents[y][x]) * r, palette[1])
	
	draw_line(player.position, player.position + get_current(currents, currents_resolution, player.position) * current_force, palette[1])

func _draw():
#	draw_currents(currents, currents_resolution)
	pass
