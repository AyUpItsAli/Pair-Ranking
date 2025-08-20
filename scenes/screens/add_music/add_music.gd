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

func _on_search_completed(data: Dictionary) -> void:
	var results: Array[Dictionary]
	if data.has("tracks"):
		results.append_array(data.tracks.items)
	if data.has("albums"):
		results.append_array(data.albums.items)
	if data.has("artists"):
		results.append_array(data.artists.items)
	for result: Dictionary in results:
		# Create item
		var item := Item.new()
		item.id = result.id
		item.name = result.name
		item.type = result.type.capitalize()
		# Icon
		var images: Array
		if result.type == "track":
			images = result.album.images
		else:
			images = result.images
		if images.is_empty():
			item.icon = Icon.new()
		else:
			item.icon = Icon.from_url(images.front().url)
		# Create entry
		var entry: MusicEntry = MUSIC_ENTRY.instantiate()
		entry.icon = item.icon
		entry.name_lbl.text = item.name
		entry.type_lbl.text = item.type
		# Artist label
		if result.has("artists"):
			var artists: Array[String]
			for artist: Dictionary in result.artists:
				artists.append(artist.name)
			entry.artist_lbl.text = ", ".join(artists)
		else:
			entry.artist_lbl.hide()
		# Add Tracks button
		if result.type == "album":
			entry.add_tracks_btn.pressed.connect(_on_music_entry_add_tracks.bind(entry, item))
		else:
			entry.add_tracks_btn.hide()
		# Add button
		if Global.ranking.items.has(item.id):
			entry.display_added()
		else:
			entry.add_btn.pressed.connect(_on_music_entry_add_item.bind(entry, item))
		music_entries.add_child(entry)
	if results.is_empty():
		search_lbl.set_text("Couldn't find any music :(")
	else:
		search_lbl.set_text("")

func _on_music_entry_add_tracks(entry: MusicEntry, album: Item) -> void:
	entry.add_tracks_btn.set_disabled(true)
	var data: Dictionary = await Spotify.get_album_tracks(album.id)
	for result: Dictionary in data.items:
		var item := Item.new()
		item.id = result.id
		item.name = result.name
		item.type = result.type.capitalize()
		item.icon = album.icon
		Global.ranking.add_item(item)
	entry.display_tracks_added()

func _on_music_entry_add_item(entry: MusicEntry, item: Item) -> void:
	entry.display_added()
	Global.ranking.add_item(item)
