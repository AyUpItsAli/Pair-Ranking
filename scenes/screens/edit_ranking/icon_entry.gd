class_name IconEntry extends PanelContainer

@export var icon_rect: TextureButton

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture_normal = await icon.get_texture()

signal selected

func _on_icon_rect_pressed() -> void:
	selected.emit()
