@tool
extends EditorScript

var battle_script_path = "scripts/battle.gd"
var state_directory_path = "scripts/states/"


func _print_file_contents(file_path: String) -> String:
	var result = ""
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		result = "file_path: `%s`\n```\n" % file_path
		var content = file.get_as_text()
		# Add tab indent to each line
		var indented_content = ""
		for line in content.split("\n"):
			indented_content += "\t" + line + "\n"
		result += indented_content
		result += "```\n"
		file.close()
	else:
		result = "File not found: " + file_path + "\n"
	return result


func _run():
	var output_text = ""

	# Process battle script
	var battle_output = _print_file_contents(battle_script_path)
	output_text += battle_output + "\n"  # Add blank line after battle script

	# Process state scripts
	var dir = DirAccess.open(state_directory_path)
	var first_state = true

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd") and !dir.current_is_dir():
				var state_output = _print_file_contents(state_directory_path.path_join(file_name))

				# Add separation between states
				if not first_state:
					output_text += "\n"
				first_state = false

				output_text += state_output
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		var error_output = "Error: Could not open directory " + state_directory_path + "\n"
		print(error_output)
		output_text += error_output

	# Write accumulated output to clipboard
	DisplayServer.clipboard_set(output_text)
	print("\nState Machine contents have been copied to clipboard!")
