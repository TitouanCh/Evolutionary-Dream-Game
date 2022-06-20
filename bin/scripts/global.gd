extends Node

var paused = false

var geneDatabase = {}
var scenarioDatabase = {}
var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]

func _ready():
	geneDatabase = DataUtilities.make_database("./data/genes", "SEQUENCE:")
	scenarioDatabase = DataUtilities.make_database("./data/scenarios", "TITLE:")

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		paused = !paused
