class_name MusicEntry extends PanelContainer

@export var icon_rect: TextureRect
@export var name_lbl: Label
@export var artist_lbl: Label
@export var type_lbl: Label
@export var add_tracks_btn: Button
@export var add_btn: Button

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture = await icon.get_texture()

func display_tracks_added() -> void:
	add_tracks_btn.set_disabled(true)
	add_tracks_btn.set_text("Tracks Added")

func display_added() -> void:
	add_btn.set_disabled(true)
	add_btn.set_text("Added")
