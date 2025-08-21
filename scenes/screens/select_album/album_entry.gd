class_name AlbumEntry extends PanelContainer

@export var icon_rect: TextureRect
@export var name_lbl: Label
@export var artist_lbl: Label
@export var type_lbl: Label
@export var create_btn: Button

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture = await icon.get_texture()
