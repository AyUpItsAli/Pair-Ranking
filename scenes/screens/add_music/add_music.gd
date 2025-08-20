extends Control

const MUSIC_ENTRY = preload("res://scenes/screens/add_music/music_entry.tscn")

@export var search_edit: LineEdit
@export var type_btn: OptionButton
@export var music_entries: VBoxContainer
@export var search_lbl: Label

func _ready() -> void:
	Spotify.search_completed.connect(_on_search_completed)
	update_music_entires()

func _on_back_btn_pressed() -> void:
	ScreenManager.go_back()

func _on_search_edit_text_changed(_new_text: String) -> void:
	update_music_entires()

func _on_type_btn_item_selected(_index: int) -> void:
	update_music_entires()

func update_music_entires() -> void:
	for entry in music_entries.get_children():
		music_entries.remove_child(entry)
		entry.queue_free()
	search_lbl.set_text("Searching...")
	var search: String = Global.non_word_chars.sub(search_edit.text, "+", true)
	var type: String = type_btn.text.to_lower()
	var query: String = "%s:%s" % [type, search]
	Spotify.search(query, type, 20)

func _on_search_completed(results: Dictionary) -> void:
	var items: Array[Dictionary]
	if results.has("tracks"):
		items.append_array(results.tracks.items)
	if results.has("albums"):
		items.append_array(results.albums.items)
	if results.has("artists"):
		items.append_array(results.artists.items)
	for item: Dictionary in items:
		var entry: MusicEntry = MUSIC_ENTRY.instantiate()
		# Icon
		var images: Array = item.album.images if item.type == "track" else item.images
		if images.is_empty():
			entry.icon = Icon.new()
		else:
			entry.icon = Icon.from_url(images.front().url)
		# Name
		entry.name_lbl.text = item.name
		# Artist
		if item.has("artists"):
			var artists: Array[String]
			for artist: Dictionary in item.artists:
				artists.append(artist.name)
			entry.artist_lbl.text = ", ".join(artists)
		else:
			entry.artist_lbl.hide()
		# Type
		entry.type_lbl.text = item.type.capitalize()
		# Add Tracks Button
		if item.type != "album":
			entry.add_tracks_btn.hide()
		music_entries.add_child(entry)
	if items.is_empty():
		search_lbl.set_text("Couldn't find any music :(")
	else:
		search_lbl.set_text("")
