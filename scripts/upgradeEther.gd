extends Node

var upgrade_title = [
"teeth  i",
"teeth  ii",
"whiskers  i",
"whiskers  ii",
"whiskers  iii",
"stronger tail"
]

var upgrade_description = [
	"+ damage",
	"+ damage",
	"+ agility",
	"+ agility",
	"+ agility",
	"+ movement"
]

var upgrade_dna = [
	"aaatt",
	"tatatt",
	"gcggg",
	"gcgttt",
	"gcatgg",
	"tcc"
]

var upgrade_meta = [
	["upgradable"],
	["locked"],
	["upgradable"],
	["upgradable", "locked"],
	["locked"],
	["repeatable"]
]

func update_lists(n):
	if upgrade_meta[n].has("upgradable"):
		upgrade_meta[n + 1].erase("locked")
		print(upgrade_meta)
	
	if !upgrade_meta[n].has("repeatable"):
		upgrade_meta[n] = ["locked"]
