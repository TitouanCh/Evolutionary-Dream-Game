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

# - Reads a line and returns a list of parsed variables
static func read_line(line, var_dict = {}):
	var raw_list = line.split(" ")
	var list = []
	
	for i in range(len(raw_list)):
		# Vector 2
		if raw_list[i][0] == "(":
			var a = raw_list[i].replace(" ", "").replace("(", "").replace(",", "")
			var b = raw_list[i + 1].replace(" ", "").replace(")", "")
			list.append(Vector2(JSON.parse(a).result, JSON.parse(b).result))
		# Arrays
		elif raw_list[i][0] == "[":
			var inside_list = [JSON.parse(raw_list[i].replace(" ", "").replace("[", "").replace("]", "").replace(",", "")).result]
			var j = i
			while !raw_list[j].ends_with("]") and !raw_list[j].ends_with("],"):
				var a = JSON.parse(raw_list[j + 1].replace(" ", "").replace("[", "").replace("]", "").replace(",", "")).result
				inside_list.append(a)
				j += 1
			list.append(inside_list)
		# Ignore rest of arr or vector
		elif raw_list[i][-1] == "]" or raw_list[i][-1] == ")" or raw_list[i][-1] == ",":
			continue
		# Sprites/AnimatedSprites
		elif raw_list[i][0] == "~":
			var directory = Directory.new();
			if directory.file_exists("res://assets/sprites/" + raw_list[i].replace("~", "") + ".png"):
				list.append(load("res://assets/sprites/" + raw_list[i].replace("~", "") + ".png"))
			if directory.file_exists("res://assets/sprites/" + raw_list[i].replace("~", "") + ".tres"):
				list.append(load("res://assets/sprites/" + raw_list[i].replace("~", "") + ".tres"))
		# Declared variable
		elif raw_list[i] in var_dict and i > 0:
			list.append(var_dict[raw_list[i]])
		# Int
		elif raw_list[i].is_valid_integer():
			list.append(int(raw_list[i]))
		# Float
		elif raw_list[i].is_valid_float():
			list.append(float(raw_list[i]))
		# Strings
		else:
			list.append(raw_list[i])
	
	return list

# - Execute a file on an object
static func execute_file_on(obj, execute_info, utility):
	var var_dict = {"a" : 0, "b" : 0, "c" : 0, "d" : 0, "e" : 0, "f" : 0, "g" : 0, "h" : 0}
	var start = false
	for line in execute_info:
		if line.begins_with(";"):
			break
		if start:
			execute_line_on(obj, line, utility, var_dict)
		elif line.begins_with("DO"):
			start = true

# - Execute a line with an object
static func execute_line_on(obj, line, utility, var_dict = {}):
	var raw_list = line.split(" ")
	var list = []
	var expression = Expression.new()
	var command = ""
	
	list = read_line(line, var_dict)
	
	# ---
	
	# Assign variable
	var n = 0
	if len(list) > 1:
		if list[1] is String:
			if list[1] == "<-":
				command = "return " + utility + "." + list[2].to_lower() + "("
				n += 3
	
	# Execute function
	if command == "":
		command = utility + "." + list[0].to_lower() + "("
	
	# Modify Organism Attribute
	if list[0] is String:
		if list[0].ends_with("++"):
			obj.set(list[0].replace("++", "").to_lower(), obj.get(list[0].replace("++", "").to_lower()) + list[1])
			return
		if list[0].ends_with("--"):
			obj.set(list[0].replace("--", "").to_lower(), obj.get(list[0].replace("--", "").to_lower()) - list[1])
			return
		if list[0].ends_with("="):
			obj.set(list[0].replace("=", "").to_lower(), list[1])
			return
	
	# Creating script
	for i in range(n, len(list)):
		command += "arr[" + str(i) + "], "
	command = command.substr(0, len(command) - 2)
	command += ")"
	
	var script = GDScript.new()
	
	script.source_code += "\nfunc run(arr):\n	" + command + "\n"
#	print(script.source_code)
	
	script.reload()
	
	# Need to create an instance of the script to call its methods
	var instance = Reference.new()
	instance.set_script(script)
	
	# Assign variable
	if len(list) > 1:
		if list[1] is String:
			if list[1] == "<-":
				var_dict[list[0]] = instance.call("run", list)
				return
	
	# Execute function
	list.remove(0)
	instance.call("run", [obj] + list)

# - Make database from a directory 
static func make_database(dir, key_str = "SEQUENCE:"):
	var database = {}
	var all_files = get_all_files_dir(dir)
	
	for file in all_files:
		var raw = read_file(dir + "/" + file)
		
		for i in range(len(raw)):
			if raw[i] == "START":
				var key = ""
				var line = []
				var j = i + 1
				while raw[j] != "STOP":
					line.append(raw[j])
					if remove_tabs_and_spaces(raw[j]).begins_with(key_str):
						key = raw[j]
					j += 1
				
				database[remove_tabs_and_spaces(key.replace(key_str, ""))] = line
	
	return database

# - Remove tabs and spaces from string
static func remove_tabs_and_spaces(string):
	return string.replace("	", "").replace(" ", "")


# - Merge Dictionaries
static func merge_dict(dict_1: Dictionary, dict_2: Dictionary, deep_merge: bool = false) -> Dictionary:
	var new_dict = dict_1.duplicate(true)
	for key in dict_2:
		if key in new_dict:
			if deep_merge and dict_1[key] is Dictionary and dict_2[key] is Dictionary:
				new_dict[key] = merge_dict(dict_1[key], dict_2[key])
			elif deep_merge and dict_1[key] is Array and dict_2[key] is Array:
				new_dict[key] = dict_1[key] + dict_2[key]
			else:
				new_dict[key] = dict_2[key]
		else:
			new_dict[key] = dict_2[key]
	return new_dict
