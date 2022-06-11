extends Reference

class_name DataUtilities

# - Looks at all the files in a directory and return them as a list 
static func get_all_files_dir(path, filter_import = true):
	var list = []
	
	var dir = Directory.new()
	
	assert(dir.open(path) == OK, "ERROR: get_all_files_dir() invalid path : " + str(path));
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			pass
		else:
			list.append(file_name)
		file_name = dir.get_next()
	
	if filter_import: list = filter_by_extension(list)
	
	return list

# - Remove files with a specific extension from a list (positive/negative filter)
static func filter_by_extension(list_of_files, list_of_extensions_positive = ["*"], list_of_extensions_negative = [".import"]):
	var filtered_list = []
	
	for i in range(len(list_of_files)):

		var negatived = false
		for b in list_of_extensions_negative:
			if list_of_files[i].ends_with(b):
				negatived = true
				break
		
		if negatived:
			continue
		
		for b in list_of_extensions_positive:
			if list_of_files[i].ends_with(b) or b == "*":
				filtered_list.append(list_of_files[i])
				break
	
	return filtered_list

# - Remove extension from a list of file names
static func remove_extension(list_of_files):
	var list = []
	for file in list_of_files:
		list.append(file.split(".")[0])
	return list

# - Read text file, ignoring comments, outputs array of all the lines
static func read_file(path, dedent = true):
	var allthelines = []        
	
	var file = File.new()
	file.open(path, file.READ)
	
	while file.get_position() < file.get_len():
		var line = file.get_line()
		if line.dedent() != "":
			if line.dedent()[0] != "#":
				if dedent: line = line.dedent()
				allthelines.append(line)
	
	file.close()
	
	return allthelines

# - Make gene database from a directory 
static func make_gene_database(gene_dir):
	var gene_database = {}
	var all_gene_files = get_all_files_dir(gene_dir)
	
	for file in all_gene_files:
		var raw = read_file(gene_dir + "/" + file)
		
		for i in range(len(raw)):
			if raw[i] == "START":
				var key = raw[i + 2]
				var gene = []
				var j = i + 1
				while raw[j] != "STOP":
					gene.append(raw[j])
					j += 1
				
				gene_database[remove_tabs_and_spaces(key.replace("SEQUENCE:", ""))] = gene
	
	return gene_database

# - Remove tabs and spaces from string
static func remove_tabs_and_spaces(string):
	return string.replace("	", "").replace(" ", "")
