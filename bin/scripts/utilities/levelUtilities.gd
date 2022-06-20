extends Reference

class_name LevelUtilities

static func execute_scenario(levelManager, execute_info):
	DataUtilities.execute_file_on(levelManager, execute_info, "LevelUtilities")

static func clear_entities(levelManager):
	levelManager.entities = {-1 : [levelManager.player.position, -1, "organism", "player"]}

static func spawn(levelManager, coord, what, type = []):
	levelManager.entities[levelManager.entities.size()] = [coord, -1, what] + type

static func move_player(levelManager, coord):
	levelManager.player.position = coord
