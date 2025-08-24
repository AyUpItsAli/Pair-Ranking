class_name Ranking extends Resource

const FOLDER = "user://rankings"
const EXTENSION = ".res"
const IMPORT_NAME = "ranking_import"

@export var id: String:
	set(new_id):
		id = new_id
		path = get_path_from_id(id)
@export var name: String
@export var icon: Icon:
	set(new_icon):
		icon = new_icon
		icons_updated.emit()
@export var path: String
@export var items: Dictionary[String, Item]
@export var icons: Array[Icon]

signal items_updated
signal icons_updated

static func verify_directory() -> void:
	if not DirAccess.dir_exists_absolute(FOLDER):
		DirAccess.make_dir_recursive_absolute(FOLDER)

static func get_path_from_id(ranking_id: String) -> String:
	return "%s/%s%s" % [FOLDER, ranking_id, EXTENSION]

static func get_rankings() -> Array[Ranking]:
	verify_directory()
	var rankings: Array[Ranking]
	for file_name: String in DirAccess.open(FOLDER).get_files():
		var ranking_id: String = file_name.get_basename()
		var ranking_path: String = get_path_from_id(ranking_id)
		var ranking: Ranking = ResourceLoader.load(ranking_path)
		if not ranking:
			push_error("Failed to load ranking: \"%s\"" % ranking_id)
			continue
		rankings.append(ranking)
	rankings.sort_custom(
		func(a: Ranking, b: Ranking) -> bool:
			return a.name < b.name
	)
	return rankings

static func import_rankings() -> void:
	var uploads: Array[Upload] = await JavaScript.upload_files(EXTENSION)
	if uploads.is_empty():
		return
	var import_path: String = "user://%s%s" % [IMPORT_NAME, EXTENSION]
	for upload: Upload in uploads:
		# Godot doesn't support loading resources directly from a byte buffer (that I'm aware of)
		# so we store the buffer to a temporary file and load it afterwards
		var file := FileAccess.open(import_path, FileAccess.WRITE)
		file.store_buffer(upload.buffer)
		file.close()
		# Load the ranking resource from the temporary file
		var ranking: Ranking = ResourceLoader.load(import_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if not ranking:
			push_error("Failed to import ranking: \"%s\"" % upload.name)
			continue
		# Clear the ranking id before saving
		# This means the imported ranking won't overwrite anything
		ranking.id = ""
		ranking.save()
	# Delete the temporary file after importing
	if FileAccess.file_exists(import_path):
		DirAccess.remove_absolute(import_path)

static func create_empty_ranking(ranking_name: String = "Untitled Ranking") -> Ranking:
	var ranking := Ranking.new()
	ranking.name = ranking_name
	ranking.icon = Icon.new()
	return ranking

func save() -> void:
	verify_directory()
	# Delete old ranking with old id (if one exists)
	delete()
	# Set new unique id
	var existing_ids: Array[String]
	for file in DirAccess.get_files_at(FOLDER):
		existing_ids.append(file.get_basename())
	id = Global.string_to_id_unique(name, existing_ids)
	# Save ranking
	var result: Error = ResourceSaver.save(self, path)
	assert(result == OK)

func delete() -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func download() -> void:
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	JavaScriptBridge.download_buffer(buffer, path.get_file())

func add_item(item: Item) -> void:
	if item.id.is_empty():
		item.id = Global.string_to_id_unique(item.name, items.keys())
	elif items.has(item.id):
		push_error("Trying to add already existing item: \"%s\"" % item.id)
		return
	items.set(item.id, item)
	items_updated.emit()
	update_icons()

func remove_item(item_id: String) -> void:
	items.erase(item_id)
	items_updated.emit()
	update_icons()

func update_icons() -> void:
	icons.clear()
	for item: Item in items.values():
		if item.icon.url.is_empty():
			continue
		var exists: bool = false
		for other_icon: Icon in icons:
			if other_icon.url == item.icon.url:
				exists = true
				break
		if not exists:
			icons.append(item.icon)
	if not icon.url.is_empty() and not icons.has(icon):
		icon = Icon.new()
	if icon.is_empty() and not icons.is_empty():
		icon = icons.front()
	icons_updated.emit()

func get_items_ranked() -> Array[Item]:
	var ranked: Array[Item] = items.values()
	ranked.sort_custom(
		func(a: Item, b: Item) -> bool:
			if a.rank == 0:
				return false
			return a.rank < b.rank
	)
	return ranked
