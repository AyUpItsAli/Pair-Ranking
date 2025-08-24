class_name IconSelector extends PanelContainer

@export var icon_rect: TextureButton

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture_normal = await icon.get_texture()

signal icon_selected(icon: Icon)

func _on_icon_rect_pressed() -> void:
	var upload: Upload = await JavaScript.upload_file("image/png,image/jpeg")
	if not upload:
		return
	var image := Image.new()
	match upload.type:
		"image/png":
			image.load_png_from_buffer(upload.buffer)
		"image/jpeg":
			image.load_jpg_from_buffer(upload.buffer)
	if image.is_empty():
		push_error("Failed to load image: \"%s\"" % upload.name)
		return
	icon = Icon.from_image(image)
	icon_selected.emit(icon)
