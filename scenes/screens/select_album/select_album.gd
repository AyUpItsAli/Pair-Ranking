extends Control

const ALBUM_ENTRY = preload("res://scenes/screens/select_album/album_entry.tscn")

@export var search_edit: LineEdit
@export var album_entries: VBoxContainer
@export var search_lbl: Label

func _ready() -> void:
	Spotify.search_completed.connect(_on_search_completed)
	update_album_entries()

func _on_back_btn_pressed() -> void:
	ScreenManager.go_back()

func _on_search_edit_text_changed(_new_text: String) -> void:
	update_album_entries()

func update_album_entries() -> void:
	for entry in album_entries.get_children():
		album_entries.remove_child(entry)
		entry.queue_free()
	search_lbl.set_text("Searching...")
	var query: String = "album:%s" % Global.non_word_chars.sub(search_edit.text, "+", true)
	Spotify.search(query, "album", 20)

func _on_search_completed(data: Dictionary) -> void:
	var results: Array[Dictionary]
	if data.has("albums"):
		results.append_array(data.albums.items)
	for result: Dictionary in results:
		# Create album
		var album := Item.new()
		album.id = result.id
		album.name = result.name
		album.type = result.type.capitalize()
		# Icon
		if result.images.is_empty():
			album.icon = Icon.new()
		else:
			album.icon = Icon.from_url(result.images.front().url)
		# Create entry
		var entry: AlbumEntry = ALBUM_ENTRY.instantiate()
		entry.icon = album.icon
		entry.name_lbl.text = album.name
		entry.type_lbl.text = album.type
		# Artist label
		if result.has("artists"):
			var artists: Array[String]
			for artist: Dictionary in result.artists:
				artists.append(artist.name)
			entry.artist_lbl.text = ", ".join(artists)
		else:
			entry.artist_lbl.hide()
		# Create button
		entry.create_btn.pressed.connect(_on_album_entry_create_ranking.bind(entry, album))
		album_entries.add_child(entry)
	if results.is_empty():
		search_lbl.set_text("Couldn't find any albums :(")
	else:
		search_lbl.set_text("")

func _on_album_entry_create_ranking(entry: AlbumEntry, album: Item) -> void:
	entry.create_btn.set_disabled(true)
	Global.ranking = Ranking.create_empty_ranking(album.name)
	var data: Dictionary = await Spotify.get_album_tracks(album.id)
	for result: Dictionary in data.items:
		var item := Item.new()
		item.id = result.id
		item.name = result.name
		item.type = result.type.capitalize()
		item.icon = album.icon
		Global.ranking.add_item(item)
	ScreenManager.go_to(ScreenManager.Screen.EDIT_RANKING)
