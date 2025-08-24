class_name Icon extends Resource

const MAX_SIZE = 300
const EMPTY_TEXTURE = preload("res://assets/images/empty_icon.png")

@export var image: Image
@export var url: String

var texture: Texture2D

static func from_image(icon_image: Image) -> Icon:
	icon_image.resize(MAX_SIZE, MAX_SIZE, Image.INTERPOLATE_LANCZOS)
	# TODO: Image compression not working in web build
	#icon_image.compress(Image.COMPRESS_ETC2)
	var icon := Icon.new()
	icon.image = icon_image
	return icon

static func from_url(icon_url: String) -> Icon:
	var icon := Icon.new()
	icon.url = icon_url
	return icon

func get_texture() -> Texture2D:
	if texture:
		return texture
	texture = await load_texture()
	return texture

func load_texture() -> Texture2D:
	if image:
		return ImageTexture.create_from_image(image)
	if url.is_empty():
		return EMPTY_TEXTURE
	var result: Array = await Http.simple_request(url)
	if result.is_empty():
		return EMPTY_TEXTURE
	var body: PackedByteArray = result[3]
	var url_image := Image.new()
	var load_error: Error = url_image.load_jpg_from_buffer(body)
	if load_error != OK:
		push_error("Error loading icon \"%s\": %s" % [url, load_error])
		return EMPTY_TEXTURE
	return ImageTexture.create_from_image(url_image)

func is_empty() -> bool:
	return image == null and url.is_empty()
