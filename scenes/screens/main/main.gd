extends Control

const RANKING_ENTRY = preload("res://scenes/screens/main/ranking_entry.tscn")

@export var new_ranking_btn: BaseButton
@export var new_ranking_menu: PanelContainer
@export var ranking_entries: VBoxContainer
@export var no_rankings_lbl: Label
@export var import_dialog: FileDialog

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

# TODO: Replace file dialog with Javascript bridge

func _on_import_ranking_btn_pressed() -> void:
	import_dialog.show()

func _on_import_dialog_files_selected(paths: PackedStringArray) -> void:
	for path in paths:
		# Load each ranking file that was selected
		var ranking: Ranking = ResourceLoader.load(path)
		if not ranking:
			push_error("Failed to load ranking \"%s\"" % path)
			continue
		# Make the id empty, so if a ranking with the same id already exists
		# the imported ranking won't overwrite it, and will instead be given a new id
		ranking.id = ""
		# Save the loaded ranking to the rankings folder (ranking has been imported)
		ranking.save()
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
