@tool
extends EditorScript

# Configuration
const BATTLE_SCRIPT_PATH = "scripts/battle.gd"
const STATE_DIRECTORY_PATH = "scripts/states/"

# State transition data storage
var state_constants = {}
var transitions = []
var state_scripts = []

# Helper: Get indent level of a line
func _get_indent_level(line: String) -> int:
	var count = 0
	for c in line:
		if c == '\t':
			count += 1
		elif c == ' ':
			count += 1  # Assuming 1 space per indent level
		else:
			break
	return count

# Helper: Convert camel case to uppercase with underscores
func _camel_to_uppercase(name: String) -> String:
	var result = ""
	var last_char_upper = false

	for i in range(name.length()):
		var c = name[i]
		if c >= 'A' and c <= 'Z':
			if i > 0 and not last_char_upper:
				result += "_"
			result += c
			last_char_upper = true
		else:
			result += c.to_upper()
			last_char_upper = false

	return result

# Parse battle.gd to extract state constants
func _parse_battle_script(content: String):
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("const STATE_"):
			var parts = line.split(":=")
			if parts.size() >= 2:
				var const_name = parts[0].replace("const", "").strip_edges()
				var const_value = parts[1].replace('"', '').strip_edges()
				state_constants[const_name] = const_value

# Parse a state script to find transitions
func _parse_state_script(file_path: String, content: String):
	var lines = content.split("\n")
	var current_function = "global"
	var current_indent = 0
	var state_name = file_path.get_file().get_basename().to_upper()

	# Convert camel case names to underscore format
	if "_" not in state_name:
		state_name = _camel_to_uppercase(state_name)

	for i in range(lines.size()):
		var line = lines[i].rstrip("\n")
		var line_stripped = line.strip_edges()
		var indent_level = _get_indent_level(line)

		# Detect function definitions
		if line_stripped.begins_with("func "):
			var func_name = line_stripped.split("func ")[1].split("(")[0].strip_edges()
			current_function = func_name
			current_indent = indent_level
			continue

		# Look for transition_state_to calls
		if "transition_state_to" in line:
			var target_state = ""

			# Extract the state constant argument
			var args_start = line.find("(")
			var args_end = line.find(")", args_start)
			if args_start != -1 and args_end != -1:
				var args_str = line.substr(args_start + 1, args_end - args_start - 1)
				var args = args_str.split(",")
				if args.size() > 0:
					var state_arg = args[0].strip_edges()

					# Handle battle.STATE_XXX format
					if "battle.STATE_" in state_arg:
						state_arg = state_arg.replace("battle.", "")

					# Handle direct string references
					if state_arg.begins_with('"'):
						target_state = state_arg.replace('"', '')
					# Handle constant references
					elif state_arg in state_constants:
						target_state = state_constants[state_arg]

			# Skip invalid transitions
			if target_state == "":
				continue

			# Find condition context
			var condition = ""
			if i > 0:
				var prev_line = lines[i-1].strip_edges()
				var prev_indent = _get_indent_level(lines[i-1])

				# Check for if statements
				if prev_line.begins_with("if ") and prev_indent == indent_level:
					condition = prev_line.replace("if", "").replace(":", "").strip_edges()
				# Check for else statements
				elif prev_line == "else:" and prev_indent == indent_level:
					condition = "else"

			# Add transition to collection
			transitions.append({
				"source": state_name,
				"target": target_state,
				"function": current_function,
				"condition": condition,
				"file": file_path.get_file(),
				"line": i + 1
			})

# Main function to process all scripts
func _run():
	# Load and parse battle.gd
	var battle_script = FileAccess.open(BATTLE_SCRIPT_PATH, FileAccess.READ)
	var battle_content = battle_script.get_as_text()
	battle_script.close()
	_parse_battle_script(battle_content)

	# Process state scripts
	var dir = DirAccess.open(STATE_DIRECTORY_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd") and !dir.current_is_dir() and file_name != "BaseState.gd":
				var file_path = STATE_DIRECTORY_PATH.path_join(file_name)
				var state_script = FileAccess.open(file_path, FileAccess.READ)
				var content = state_script.get_as_text()
				state_script.close()

				state_scripts.append({
					"file": file_name,
					"content": content
				})

				_parse_state_script(file_path, content)
			file_name = dir.get_next()

	# Generate Mermaid diagram
	var diagram = "stateDiagram-v2\n"
	diagram += "    direction LR\n"
	diagram += "    [*] --> " + state_constants.values()[0] + "\n"

	# Add transitions
	for t in transitions:
		var label = t.function
		if t.condition != "":
			label += "\\n(" + t.condition + ")"
		diagram += "    " + t.source + " --> " + t.target + " : " + label + "\n"

	# Add final state transition
	diagram += "    " + state_constants["STATE_GAME_END"] + " --> [*]\n"

	# Add notes about state scripts
	diagram += "\n    note right of [*]\n"
	diagram += "      State Machine Details:\n"
	for state in state_constants.values():
		diagram += "      " + state + " State\n"
	diagram += "    end note\n"

	# Print results
	print("Extracted State Constants:")
	for const_name in state_constants:
		print("  " + state_constants[const_name] + " = " + state_constants[const_name])

	print("\nDetected Transitions:")
	for t in transitions:
		print("  %s -> %s (via %s in %s:%d)" % [
			t.source, t.target, t.function, t.file, t.line
		])

	print("\nGenerated Mermaid Diagram:")
	print("")
	print(diagram)

	# Copy to clipboard
	DisplayServer.clipboard_set(diagram)
	print("\nDiagram copied to clipboard!")
