extends Node

var paused = false

var geneDatabase = {}
var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]

func _ready():
	geneDatabase = DataUtilities.make_gene_database("./data/genes")

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		paused = !paused
