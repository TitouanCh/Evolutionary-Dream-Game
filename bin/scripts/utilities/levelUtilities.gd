extends Reference

class_name LevelUtilities

static func execute_scenario(levelManager, execute_info):
	DataUtilities.execute_file_on(levelManager, execute_info, "LevelUtilities")

static func clear_entities(levelManager):
	levelManager.entities = {}
	for key in levelManager.instance_annuaire:
		for arr in levelManager.instance_annuaire[key]:
			deactivate(arr[0], key)
			arr[1] = false

static func deactivate(instance, type):
	if instance is Sprite:
		instance.visible = false
		return
	
	if type == "organism":
		instance.set_active(false)
		return

static func spawn(levelManager, coord, what, type = []):
	levelManager.entities[levelManager.entities.size()] = [coord, -1, what] + type

static func move_player(levelManager, coord):
	levelManager.player.position = coord

static func setup_player(levelManager, player_dna):
	levelManager.player.setup(player_dna, "player", levelManager, levelManager.soundmanager)
