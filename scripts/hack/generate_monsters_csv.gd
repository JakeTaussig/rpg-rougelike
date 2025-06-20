@tool
extends EditorScript

class_name MonsterExporter

func _run():
	# Directory path containing Monster resources
	var monsters_dir = "res://assets/monsters"

	# Output CSV file path
	var output_file = "res://docs/monsters.csv"

	# Get all files in the monsters directory
	var files = _get_files_in_directory(monsters_dir)

	# Filter for .tres files
	var monster_files = files.filter(func(file): return file.ends_with(".tres"))

	if monster_files.is_empty():
		print("No .tres files found in ", monsters_dir)
		return

	# Load the first resource to get property names for CSV header
	var sample_monster = load(monster_files[0])
	var property_names = _get_monster_property_names(sample_monster)

	# Create CSV content
	var csv_lines = []

	# Add header row
	csv_lines.append(_make_csv_line(property_names))

	# Process each monster file
	for monster_path in monster_files:
		var monster = load(monster_path)
		if monster:
			var values = []
			for prop in property_names:
				var value = monster.get(prop)
				if prop == "type":
					var type_name = MovesList.Type.keys()[value]
					values.append(type_name)
				else:
					values.append(str(value))
			csv_lines.append(_make_csv_line(values))
		else:
			printerr("Failed to load monster at: ", monster_path)

	# Write to file
	var file = FileAccess.open(output_file, FileAccess.WRITE)
	if file:
		for line in csv_lines:
			file.store_line(line)
		file.close()
		print("Successfully exported ", monster_files.size(), " monsters to ", output_file)
	else:
		printerr("Failed to open file for writing: ", output_file)

# Helper function to get all files in a directory recursively
func _get_files_in_directory(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = path.path_join(file_name)
				if dir.current_is_dir():
					files.append_array(_get_files_in_directory(full_path))
				else:
					files.append(full_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Could not open directory: ", path)

	return files

# Helper function to get property names from a Monster resource
func _get_monster_property_names(monster: Resource) -> Array:
	var properties = []
	var property_list = monster.get_property_list()

	# List of built-in properties to exclude
	var excluded = [
		"Resource", "resource_name", "resource_path",
		"resource_local_to_scene", "script", "moves",
		"metadata/_custom_type_script", "texture"
	]

	for property in property_list:
		var name = property["name"]

		# Skip excluded properties and methods
		if name in excluded:
			continue
		if property["usage"] & PROPERTY_USAGE_CATEGORY:
			continue
		if property["usage"] & PROPERTY_USAGE_GROUP:
			continue

		# Include only properties with editor/storage flags
		if property["usage"] & PROPERTY_USAGE_EDITOR and property["usage"] & PROPERTY_USAGE_STORAGE:
			properties.append(name)

	return properties

# Helper function to create a CSV line from an array of values
func _make_csv_line(values: Array) -> String:
	var escaped_values = []
	for value in values:
		var str_value = str(value)
		# Escape quotes and commas
		str_value = str_value.replace('"', '""')
		if str_value.contains(",") or str_value.contains('"') or str_value.contains("\n"):
			str_value = '"%s"' % str_value
		escaped_values.append(str_value)

	return ",".join(escaped_values)
