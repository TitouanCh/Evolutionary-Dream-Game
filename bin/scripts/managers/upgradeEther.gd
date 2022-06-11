extends Node

var upgrade_title = []

var upgrade_description = []

var upgrade_dna = []

var upgrade_meta = []

func load_upgrades(database):
	for gene in database:
		
		# Get tags
		var tags = []
		for i in range(len(database[gene])):
			if database[gene][i].begins_with("DO"):
				break
			elif database[gene][i].begins_with("UPGRADETAGS:"):
				tags = DataUtilities.remove_tabs_and_spaces(database[gene][i].replace("UPGRADETAGS:", "")).split(",")
		
		# Check nonavailable/unavailable
		tags = Array(tags)
		if tags.has("unavailable") or tags.has("nonavailable"):
			continue
		
		# Add upgrade info to ether
		for j in range(len(database[gene])):
			if database[gene][j].begins_with("DO"):
				break
			elif database[gene][j].begins_with("SEQUENCE:"):
				upgrade_dna.append(DataUtilities.remove_tabs_and_spaces(database[gene][j].replace("SEQUENCE:", "")))
			elif database[gene][j].begins_with("DESCRIPTION:"):
				upgrade_description.append(DataUtilities.remove_tabs_and_spaces(database[gene][j].replace("DESCRIPTION:", "")).replace("_", " "))
			elif database[gene][j].begins_with("TITLE:"):
				upgrade_title.append(DataUtilities.remove_tabs_and_spaces(database[gene][j].replace("TITLE:", "")).replace("_", " "))
		
		upgrade_meta.append(tags)

#	print(upgrade_title)
#	print(upgrade_description)
#	print(upgrade_dna)
#	print(upgrade_meta)

func _ready():
	load_upgrades(Global.geneDatabase)

func update_lists(n):
	if upgrade_meta[n].has("upgradable"):
		for meta in upgrade_meta:
			for i in range(len(meta)):
				if meta[i].begins_with(upgrade_title[n].replace(" ", "_")):
					meta.remove(i)
					break
	
	if !upgrade_meta[n].has("repeatable"):
		upgrade_meta[n] = ["locked"]

static func idx_is_locked(n, meta):
	for i in range(len(meta[n])):
		if meta[n][i].ends_with("locked"):
			return true
	return false
