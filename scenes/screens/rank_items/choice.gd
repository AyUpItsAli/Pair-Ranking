class_name Choice extends PanelContainer

const FADE_IN_TIME = 0.2
const COLOR_FADE_TIME = 0.2
const GLIDE_TIME = 0.3
const GLIDE_HEIGHT = 70
const GLIDE_INTERVAL = 0.2

@export var icon_rect: TextureRect
@export var name_lbl: Label
@export var type_lbl: Label

var item: Item:
	set(new_item):
		item = new_item
		icon_rect.texture = await item.icon.get_texture()
		name_lbl.text = item.name
		type_lbl.text = item.type

signal pressed

func _ready() -> void:
	reset()

func reset() -> void:
	modulate = Color(1, 1, 1, 0)
	# Hiding and showing forces position to reset
	hide()
	show()

func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, FADE_IN_TIME)
	await tween.finished

func selected() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.SPRING_GREEN, COLOR_FADE_TIME)
	tween.tween_property(self, "modulate:a", 0, GLIDE_TIME)
	tween.parallel().tween_property(self, "position:y", position.y-GLIDE_HEIGHT, GLIDE_TIME)
	tween.tween_interval(GLIDE_INTERVAL)
	await tween.finished
	reset()

func not_selected() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, COLOR_FADE_TIME)
	tween.tween_property(self, "modulate:a", 0, GLIDE_TIME)
	tween.parallel().tween_property(self, "position:y", position.y+GLIDE_HEIGHT, GLIDE_TIME)
	tween.tween_interval(GLIDE_INTERVAL)
	await tween.finished
	reset()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
