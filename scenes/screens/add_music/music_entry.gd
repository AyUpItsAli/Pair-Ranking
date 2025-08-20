class_name MusicEntry extends PanelContainer

@export var icon_rect: TextureRect
@export var name_lbl: Label
@export var artist_lbl: Label
@export var type_lbl: Label
@export var add_tracks_btn: Button

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture = await icon.get_texture()

signal add_tracks
signal add_item

func _on_add_tracks_btn_pressed() -> void:
	add_tracks.emit()

func _on_add_btn_pressed() -> void:
	add_item.emit()
