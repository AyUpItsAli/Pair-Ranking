class_name Ranking extends Resource

const FOLDER = "user://rankings"
const EXTENSION = "tres"

@export var id: String
@export var name: String
@export var icon: Icon:
	set(new_icon):
		icon = new_icon
		icons_updated.emit()
@export var items: Dictionary[String, Item]
@export var icons: Array[Icon]

signal items_updated
signal icons_updated

static func verify_directory() -> void:
	if not DirAccess.dir_exists_absolute(FOLDER):
		DirAccess.make_dir_recursive_absolute(FOLDER)

static func get_path_from_id(ranking_id: String) -> String:
	return "%s/%s.%s" % [FOLDER, ranking_id, EXTENSION]

static func get_rankings() -> Array[Ranking]:
	verify_directory()
	var rankings: Array[Ranking]
	for file in DirAccess.open(FOLDER).get_files():
		var path: String = get_path_from_id(file.get_basename())
		var ranking: Ranking = ResourceLoader.load(path)
		if not ranking:
			push_error("Failed to load ranking \"%s\"" % path)
			continue
		rankings.append(ranking)
	rankings.sort_custom(
		func(a: Ranking, b: Ranking) -> bool:
			return a.name < b.name
	)
	return rankings

static func create_untitled_ranking() -> Ranking:
	var ranking := Ranking.new()
	ranking.name = "Untitled Ranking"
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
	var path: String = get_path_from_id(id)
	var result: Error = ResourceSaver.save(self, path)
	assert(result == OK)

func delete() -> void:
	var path: String = get_path_from_id(id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func get_items_ranked() -> Array[Item]:
	var ranked: Array[Item] = items.values()
	ranked.sort_custom(
		func(a: Item, b: Item) -> bool:
			return a.rank < b.rank
	)
	return ranked

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
