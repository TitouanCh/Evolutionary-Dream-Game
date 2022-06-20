extends Node2D

onready var player = get_parent().get_node("levelManager").get_node("player")
onready var levelManager = get_parent().get_node("levelManager")


export var width = 400
export var height = 400

# --- BASE ---

func _ready():
	self.visible = false
	setup_window()
	
	setup_scenario()

func _process(delta):
	self.position = player.position - Vector2(width, height)/2
	$debug_cursor.position = get_local_mouse_position() + Vector2(8, 8)
	$debug_cursor.visible = $background.get_rect().has_point(get_local_mouse_position())
	
	if Input.is_action_just_pressed("debug"):
		self.visible = !self.visible
		if self.visible:
			Global.paused = true
		else:
			Global.paused = false
	
	if Input.is_action_just_pressed("test"):
		hijack_scenario("test")

func setup_window():
	$background.rect_size = Vector2(width, height)

# --- SCENARIO TESTER ---

onready var scenario = $scenarioTester
onready var scenarioOptions = scenario.get_node("options")

func setup_scenario():
	scenarioOptions.add_item("choose scenario")
	scenarioOptions.add_separator()
	
	for scenario_name in Global.scenarioDatabase.keys():
		scenarioOptions.add_item(scenario_name)

func hijack_scenario(scenario):
	LevelUtilities.execute_scenario(levelManager, Global.scenarioDatabase["test"])

func _on_scenarioTester_start_pressed():
	if Global.scenarioDatabase.keys().has(scenarioOptions.text):
		hijack_scenario(scenarioOptions.text)
