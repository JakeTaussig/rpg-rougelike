@tool
extends EditorScript

class_name MoveExporter

func _run():
	# Directory path containing Move resources
	var moves_dir = "res://resources/moves"

	# Output CSV file path
	var output_file = "res://docs/moves.csv"

	# Get all files in the moves directory
	var files = _get_files_in_directory(moves_dir)

	# Filter for .tres files
	var move_files = files.filter(func(file): return file.ends_with(".tres"))

	if move_files.is_empty():
		print("No .tres files found in ", moves_dir)
		return

	# Load the first resource to get property names for CSV header
	var sample_move = load(move_files[0])
	var property_names = _get_move_property_names(sample_move)

	# Create CSV content
	var csv_lines = []

	# Add header row
	csv_lines.append(_make_csv_line(property_names))

	# Process each move file
	for move_path in move_files:
		var move = load(move_path)
		if move:
			var values = []
			for prop in property_names:
				var value = move.get(prop)
				if prop == "type":
					var type_name = MovesList.Type.keys()[value]
					values.append(type_name)
				elif prop == "category":
					var prop_name = Move.MoveCategory.keys()[value]
					values.append(prop_name)
				elif prop == "status_effect":
					var status_effect_name = MovesList.StatusEffect.keys()[value]
					values.append(status_effect_name)
				else:
					values.append(str(value))
			csv_lines.append(_make_csv_line(values))
		else:
			printerr("Failed to load move at: ", move_path)

	# Write to file
	var file = FileAccess.open(output_file, FileAccess.WRITE)
	if file:
		for line in csv_lines:
			file.store_line(line)
		file.close()
		print("Successfully exported ", move_files.size(), " moves to ", output_file)
	else:
		printerr("Failed to open file for writing: ", output_file)

func _get_files_in_directory(path: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			files.append(path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("Could not open directory: ", path)

	return files

# Helper function to get property names from a Move resource
func _get_move_property_names(move: Resource) -> Array:
	var properties = []
	var property_list = move.get_property_list()

	# List of built-in properties to exclude
	var excluded = [
		"Resource", "resource_name", "resource_path",
		"resource_local_to_scene", "script", "priority",
		"metadata/_custom_type_script"
	]

	for property in property_list:
		var name = property["name"]

		# Skip excluded properties
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
