class_name IconSelector extends PanelContainer

@export var icon_rect: TextureButton
@export var file_dialog: FileDialog

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture_normal = await icon.get_texture()

signal icon_selected(icon: Icon)

func _on_icon_rect_pressed() -> void:
	file_dialog.show()

func _on_file_dialog_file_selected(path: String) -> void:
	icon = Icon.from_image(Image.load_from_file(path))
	icon_selected.emit(icon)
