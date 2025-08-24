extends Control

const RANKING_ENTRY = preload("res://scenes/screens/main/ranking_entry.tscn")

@export var new_ranking_btn: BaseButton
@export var new_ranking_menu: PanelContainer
@export var ranking_entries: VBoxContainer
@export var no_rankings_lbl: Label

func _ready() -> void:
	Global.ranking = null
	new_ranking_btn.show()
	new_ranking_menu.hide()
	update_ranking_entires()

func _on_new_ranking_btn_pressed() -> void:
	new_ranking_btn.hide()
	new_ranking_menu.show()

func _on_album_ranking_btn_pressed() -> void:
	ScreenManager.go_to(ScreenManager.Screen.SELECT_ALBUM)

func _on_empty_ranking_btn_pressed() -> void:
	Global.ranking = Ranking.create_empty_ranking()
	ScreenManager.go_to(ScreenManager.Screen.EDIT_RANKING)

func _on_import_ranking_btn_pressed() -> void:
	var uploads: Array[Upload] = await JavaScript.upload_files(Ranking.EXTENSION)
	if uploads.is_empty():
		return
	var import_path: String = "user://%s%s" % [Ranking.IMPORT_NAME, Ranking.EXTENSION]
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
	update_ranking_entires()

func update_ranking_entires() -> void:
	for entry in ranking_entries.get_children():
		ranking_entries.remove_child(entry)
		entry.queue_free()
	var rankings: Array[Ranking] = Ranking.get_rankings()
	for ranking: Ranking in rankings:
		var entry: RankingEntry = RANKING_ENTRY.instantiate()
		entry.text = ranking.name
		entry.ranking_icon = ranking.icon
		entry.pressed.connect(_on_ranking_entry_pressed.bind(ranking))
		ranking_entries.add_child(entry)
	no_rankings_lbl.visible = rankings.is_empty()

func _on_ranking_entry_pressed(ranking: Ranking) -> void:
	Global.ranking = ranking
	ScreenManager.go_to(ScreenManager.Screen.VIEW_RANKING)
