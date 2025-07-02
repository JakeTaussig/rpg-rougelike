extends Resource
class_name TrinketsList

var trinkets: Array[Trinket] = []


func _init():
	_load_trinkets_from_folder()


func _load_trinkets_from_folder(path: String = "res://resources/trinkets"):
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var trinket_path = path + "/" + file_name
			var trinket_resource = load(trinket_path)
			if trinket_resource is Trinket:
				trinkets.append(
					trinket_resource.duplicate_deep(
						Resource.DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL
					)
				)
		file_name = dir.get_next()
	dir.list_dir_end()
