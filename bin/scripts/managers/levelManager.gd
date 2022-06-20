extends Node2D

# - Get other nodes
onready var player = get_node("player")
onready var soundmanager = get_parent().get_node("audioManager")

# - Main parameters
var palette = [Color(255), Color(255), Color(255), Color(255)]
const big_distance = 524288*2
const small_distance = 512

var once = false

# - Entities
var entities = {
	-1 : [Vector2.ZERO, -1, "organism", "player"]
}


var food = []
var foodSprites = []
var foodText = preload("res://assets/sprites/16Circle.png")

var debris = []
var debrisSprites = []
var debrisText = preload("res://assets/sprites/1Pixel.png")

var explosionSystems = []
var explosionScene = preload("res://bin/scenes/objects/explosionParticleSystem.tscn")

# npc format, [position, dna, behavior, loaded]
var npc = []
var npcInstances = []
var npcScene = preload("res://bin/scenes/objects/organism.tscn")

var border_sprites = []
var border_texture = preload("res://assets/sprites/32Border.png")

var instance_annuaire = {
	"food" : foodSprites,
	"debris" : debrisSprites,
	"explosionSystem" : explosionSystems,
	"organism" : npcInstances,
	"border" : border_sprites
}

# Currents
var currents = []
var currents_resolution = 64
var current_force = 40
var depth = 0

var current_mod_table = {
	"food" : 2,
	"debris" : 6,
	"explosionSystem" : 1,
	"organism" : 1,
	"border" : 1
}


func _ready():
	currents = make_currents(512)
	player.setup("atgcatgc", "player", self, soundmanager)

func _once():
	setup_sprites(64, foodText, foodSprites, palette[2])
	setup_sprites(128, debrisText, debrisSprites, palette[1])
	setup_sprites(58, border_texture, border_sprites, palette[0], -1)
	
	setup_scenes(8, explosionScene, explosionSystems, palette[2])
	setup_npcs(8)
	
	spawn_randomly(600, entities, "food", [], Vector2(0, 16384), Vector2(0, 16384))
	spawn_randomly(100, entities, "organism", ["herbivore", "agccgtt"], Vector2(0, 16384), Vector2(0, 16384))
	spawn_randomly(10, entities, "organism", ["herbivore", "atgcatgctccaaatt"], Vector2(0, 16384), Vector2(0, 16384))
	spawn_randomly(420, entities, "debris", [], Vector2(0, 200), Vector2(0, 200))
	
#	spawn_food_randomly(600, food, Vector2(0, 16384), Vector2(0, 16384))
#	spawn_npcs_randomly(100, npc, Vector2(0, 16384), Vector2(0, 16384), "agccgtt")
#	spawn_npcs_randomly(10, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")
#	spawn_debris(420, debris, Vector2(0, 200), Vector2(0, 200))

#	print(entities)

func progress(n):
	depth += n
	current_force += 5
	if depth % 6 == 1:
		spawn_npcs_randomly(100, npc, Vector2(0, 16384), Vector2(0, 16384), "agccgtt")
		spawn_npcs_randomly(10, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")
	if depth % 6 == 3:
		spawn_food_randomly(600, food, Vector2(0, 16384), Vector2(0, 16384))
	if depth % 6 == 4:
		spawn_npcs_randomly(60, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatt")
	if depth % 12 == 11:
		spawn_npcs_randomly(20, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaattgcggggcgttttcc")
	if depth % 6 == 5:
		spawn_npcs_randomly(1, npc, Vector2(0, 16384), Vector2(0, 16384), "atgcatgctccaaatttatatttcctcctcctcctcctccgcggggcgtttgcatgg")

func _process(delta):
	if !Global.paused:
		if !once:
			_once()
			once = true
#		handle_food(delta, food)
#		handle_npc(delta, npc, food)
#		handle_debris(delta, debris)
		handle_border(border_sprites)
		handle_all(entities, delta)
		
		player.linear_velocity += get_current(currents, currents_resolution, player.position) * current_force * delta
		update()

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Setup functions
func setup_sprites(n, text, list, color, z = 0):
	for i in range(n):
		var a = Sprite.new()
		self.add_child(a)
		a.texture = text
		a.visible = false
		list.append([a, false])
		a.modulate = color
		a.z_index = z

func setup_scenes(n, scene, list, color):
	for i in range(n):
		var a = scene.instance()
		self.add_child(a)
		list.append([a, false])
		a.modulate = color

# - Temporary ???
func setup_npcs(n):
	for i in range(n):
		var a = npcScene.instance()
		self.add_child(a)
		npcInstances.append([a, false])
		a.setup("agccgtt", "herbivore", self, soundmanager)
		a.set_active(false)
		OrganismUtilities.recolor(a, palette, a.body_sprite, a.neutral_sprites, a.tail, a.fangs)

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Handle functions
func handle_all(entity_list, delta):
	entity_list[-1][0] = player.position
	var keys_to_erase = []
	
	for key in entity_list:
		# - Actual handle
		var distance = entity_list[key][0].distance_squared_to(player.position)
		var dead = false
		
		# - If close to player but not instanciated -> instanciate
		if distance < big_distance and !(entity_list[key][1] + 1):
			var instance_list = instance_annuaire[entity_list[key][2]]
			
			for i in range(len(instance_list)):
				if !instance_list[i][1]:
					entity_list[key][1] = i
					instance_list[i][1] = true
					break
			
			instance_list[entity_list[key][1]][0].position = entity_list[key][0]
			
			# - Specifics
			if instance_list[entity_list[key][1]][0] is Sprite:
				instance_list[entity_list[key][1]][0].visible = true
			
			if entity_list[key][2] == "organism" and entity_list[key][3] != "player":
				instance_list[entity_list[key][1]][0].DNA = entity_list[key][4]
				instance_list[entity_list[key][1]][0]._once()
				instance_list[entity_list[key][1]][0].rotation = randf() * PI * 2
				instance_list[entity_list[key][1]][0].set_active(true)
		
		# - If already instanciated
		elif entity_list[key][1] + 1:
			var instance_list = instance_annuaire[entity_list[key][2]]
			
			# - If too far away
			if instance_list[entity_list[key][1]][0].position.distance_squared_to(player.position) > big_distance:
				
				instance_list[entity_list[key][1]][1] = false
				entity_list[key][1] = -1
				
				# - Specifics
				if instance_list[entity_list[key][1]][0] is Sprite:
					instance_list[entity_list[key][1]][0].visible = false
				
				if entity_list[key][2] == "organism":
					instance_list[entity_list[key][1]][0].set_active(false)
			
			# - Regular Behaviors
			else:
				
				# - Currents
				var current_mod = current_mod_table[entity_list[key][2]]

				instance_list[entity_list[key][1]][0].position += get_current(currents, currents_resolution, entity_list[key][0]) * current_force * current_mod * delta
				
				# - Specifics
				if entity_list[key][2] == "food":
					for entity in instance_annuaire["organism"] + [[player, true]]:
						if entity_list[key][0].distance_squared_to(entity[0].position) < small_distance and entity[1]:
#							explosionSystems[explosionSystems[0] + 1].position = f[i]
#							explosionSystems[explosionSystems[0] + 1].emitting = true
#							explosionSystems[explosionSystems[0] + 1].process_material.set_shader_param("impact", entity.linear_velocity)
							dead = entity[0].linear_velocity
#							print(entity)
#							idx_remove_list.append(i)
							soundmanager.play_sound("eat")
							entity[0].scaleInfo[0] = 0
							entity[0].belly += 1
							entity[0].fang_speed += 40
							
#							explosionSystems[0] += 1
#							if explosionSystems[0] == len(explosionSystems) - 1:
#								explosionSystems[0] = 0
							break
				
				if entity_list[key][2] == "organism":
					var closest_food = Vector2.ZERO
					var smallest_distance = big_distance*2*2
					for j in entity_list:
						if entity_list[j][2] == "food":
							var dist = entity_list[j][0].distance_squared_to(instance_list[entity_list[key][1]][0].position)
							if dist < smallest_distance:
								closest_food = entity_list[j][0]
								smallest_distance = dist
					instance_list[entity_list[key][1]][0].target = closest_food
				
				if entity_list[key][2] == "debris":
					instance_list[entity_list[key][1]][0].position += Vector2(randf() * 3 - 1.5, randf() * 3 - 1.5)
			
			entity_list[key][0] = instance_list[entity_list[key][1]][0].position
	
		# - If not instanciated/OoB
		else:
			# - Currents
			var current_mod = current_mod_table[entity_list[key][2]]
			entity_list[key][0] += get_current(currents, currents_resolution, entity_list[key][0]) * current_force * current_mod * delta
				
			# - Specifics
			if entity_list[key][2] == "debris":
				entity_list[key][0] = Vector2(randf() * 4000 - 2000 + player.position.x, randf() * 4000 - 2000 + player.position.y)
		
		if dead:
			var instance_list = instance_annuaire[entity_list[key][2]]
			instance_list[entity_list[key][1]][0].visible = false
			instance_list[entity_list[key][1]][1] = false
			entity_list[key][1] = -1
			
			for explosion in explosionSystems:
				if !explosion[1]:
					explosion[0].position = entity_list[key][0]
					explosion[0].emitting = true
					explosion[0].process_material.set_shader_param("impact", dead)
			
			keys_to_erase.append(key)
	
	for key in keys_to_erase:
		entity_list.erase(key)

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
				soundmanager.play_sound("eat")
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

func handle_border(f):
	if player.position.x < 900:
		for i in range(0, 29):
			border_sprites[i][0].position = Vector2(-16, player.position.y - 450 + i * 32)
		
			if border_sprites[i][0].position.y < -16 or border_sprites[i][0].position.y > 16384 + 16:
					border_sprites[i][0].visible = false
			else:
				border_sprites[i][0].visible = true
	
	if player.position.x > 16384 - 900:
		for i in range(0, 29):
			border_sprites[i][0].position = Vector2(16384 + 16, player.position.y - 450 + i * 32)
		
			if border_sprites[i][0].position.y < -16 or border_sprites[i][0].position.y > 16384 + 16:
					border_sprites[i][0].visible = false
			else:
				border_sprites[i][0].visible = true
	
	if player.position.y < 900:
		for i in range(29, 58):
			border_sprites[i][0].position = Vector2(player.position.x - 450 + (i - 29) * 32, -16) 
			
			if border_sprites[i][0].position.x < -16 or border_sprites[i][0].position.x > 16384 + 16:
				border_sprites[i][0].visible = false
			else:
				border_sprites[i][0].visible = true
	
	if player.position.y > 16384 - 900:
		for i in range(29, 58):
			border_sprites[i][0].position = Vector2(player.position.x - 450 + (i - 29) * 32, 16384 + 16) 
			
			if border_sprites[i][0].position.x < -16 or border_sprites[i][0].position.x > 16384 + 16:
				border_sprites[i][0].visible = false
			else:
				border_sprites[i][0].visible = true

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

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Spawn functions
func spawn_randomly(n, entity_list, what, type, xbor, ybor):
	for i in range(n):
		randomize()
		var entity_position = Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))) 
		entity_list[entity_list.size()] = [entity_position, -1, what] + type

func spawn(coord, entity_list, what, type):
	entity_list[entity_list.size()] = [coord, -1, what] + type

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

func spawn_npcs_randomly(n, f, xbor, ybor, dna):
	for i in range(n):
		randomize()
		f.append([Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))), dna, "b", 0])


# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Other

# - recolor everything TODO : Modify
func recolor(p):
	palette = p
	for i in range(0, len(foodSprites)):
		foodSprites[i][0].modulate = p[2]
	for i in range(0, len(debrisSprites)):
		debrisSprites[i][0].modulate = p[1]
	for i in range(0, len(explosionSystems)):
		explosionSystems[i][0].modulate = p[2]
	for i in range(0, len(npcInstances)):
		OrganismUtilities.recolor(npcInstances[i][0], p, npcInstances[i][0].body_sprite, npcInstances[i][0].neutral_sprites, npcInstances[i][0].tail, npcInstances[i][0].fangs)
	for i in range(0, len(border_sprites)):
		border_sprites[i][0].modulate = p[0]

# -----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----| @ |-----

# -- Current functions
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
	if pos.x < 16384 and pos.x > 0 and pos.y < 16384 and pos.y > 0:
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
	
	else:
		return Vector2.ZERO

func draw_currents(c, r):
	for y in range(len(currents)):
		for x in range(len(currents[y])):
			if Vector2(x * r, y * r).distance_squared_to(player.position) < 262144:
				draw_line(Vector2(x, y) * r, (Vector2(x, y) + currents[y][x]) * r, palette[1])
	
	draw_line(player.position, player.position + get_current(currents, currents_resolution, player.position) * current_force, palette[1])

func _draw():
#	draw_currents(currents, currents_resolution)
	pass
