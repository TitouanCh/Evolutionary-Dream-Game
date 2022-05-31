extends Node2D

onready var player = get_parent().get_node("player")

var once = false

var food = []
var foodSprites = [0]
var foodText = preload("res://sprites/16Circle.png")

var palette = [Color(255), Color(255), Color(255), Color(255)]

var explosionSystems = [0]
var explosionScene = preload("res://scenes/explosionParticleSystem.tscn")

# npc format, [position, specie, behavior, loaded]
var npc = []
var npcInstances = [0]
var npcScene = preload("res://scenes/npc.tscn")

func _once():
	setup_food_sprites(64, foodText)
	setup_explosion_systems(8)
	setup_npcs(8)
	
	spawn_food_randomly(600, food, Vector2(-6000, 6000), Vector2(6000, -6000))
	spawn_npcs_randomly(100, npc, Vector2(-6000, 6000), Vector2(6000, -6000))

func _process(delta):
	if !once:
		_once()
		once = true
	handle_food(delta, food)
	handle_npc(delta)

func setup_food_sprites(n, text):
	for i in range(n):
		var a = Sprite.new()
		self.add_child(a)
		a.texture = text
		a.visible = false
		foodSprites.append(a)
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
		OrganismUtilities.recolor(a, palette, a.body_sprite, a.neutral_sprites, a.tail)

func handle_food(d, f):
	var idx_remove_list = []
	for i in range(len(f)):
		for w in range(len(npcInstances)):
			var entity = player
			if w > 0:
				entity = npcInstances[w]
			var distance = f[i].distance_squared_to(entity.position)
			if  distance < 262144:
				foodSprites[foodSprites[0] + 1].visible = true
				foodSprites[foodSprites[0] + 1].position = f[i]
				foodSprites[0] += 1
				if foodSprites[0] == len(foodSprites) - 1:
					foodSprites[0] = 0
			if distance < 256:
				explosionSystems[explosionSystems[0] + 1].position = f[i]
				explosionSystems[explosionSystems[0] + 1].emitting = true
				explosionSystems[explosionSystems[0] + 1].process_material.set_shader_param("impact", entity.linear_velocity)
				entity.scaleInfo[0] = 0
				for j in range(1, len(foodSprites)):
					if foodSprites[j].position == f[i]:
						foodSprites[j].visible = false
				f[i] = null
				idx_remove_list.append(i)
				explosionSystems[0] += 1
				if explosionSystems[0] == len(explosionSystems) - 1:
					explosionSystems[0] = 0
				break
	
	for i in idx_remove_list:
		f.remove(i)

func spawn_food_randomly(n, f, xbor, ybor):
	for i in range(n):
		randomize()
		f.append(Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))))

func spawn_npcs_randomly(n, f, xbor, ybor):
	for i in range(n):
		randomize()
		f.append([Vector2(xbor.x + (randf() * (xbor.y - xbor.x)), ybor.x + (randf() * (ybor.y - ybor.x))), "mimi", "b", 0])

func handle_npc(delta):
	for i in range(len(npc)):
		var distance = npc[i][0].distance_squared_to(player.position)
		if  distance < 262144 and !npc[i][3]:
			for j in range(1, len(npcInstances)):
				if !npcInstances[j].active: npcInstances[0] = j
			npcInstances[npcInstances[0]].position = npc[i][0]
			npcInstances[npcInstances[0]].rotation = randf() * PI * 2
			npcInstances[npcInstances[0]].set_active(true)
			npc[i][3] = npcInstances[0]
		elif npc[i][3]:
			if npcInstances[npc[i][3]].position.distance_squared_to(player.position) > 262144:
				npc[i][0] = npcInstances[npc[i][3]].position
				npcInstances[npc[i][3]].set_active(false)
				npc[i][3] = 0
			else:
				var closest_food = Vector2.ZERO
				var smallest_distance = 262144*2*2
				for j in range(len(food)):
					var dist = food[j].distance_squared_to(npcInstances[npc[i][3]].position)
					if dist < smallest_distance:
						closest_food = food[j]
						smallest_distance = dist
				npcInstances[npc[i][3]].target = closest_food
		else:
			npc[i][0] += Vector2(randf()-0.5, randf()-0.5) * delta * 10

func recolor(p):
	palette = p
	for i in range(1, len(foodSprites)):
		foodSprites[i].modulate = p[2]
	for i in range(1, len(explosionSystems)):
		explosionSystems[i].modulate = p[2]
	for i in range(1, len(npcInstances)):
		OrganismUtilities.recolor(npcInstances[i], p, npcInstances[i].body_sprite, npcInstances[i].neutral_sprites, npcInstances[i].tail)
