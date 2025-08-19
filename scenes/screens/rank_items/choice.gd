class_name Choice extends PanelContainer

const NORMAL_SIZE = 250
const GROW_SIZE = 300

@export var icon_rect: TextureRect
@export var name_lbl: Label

var item: Item

signal chosen(item: Item)

func _ready() -> void:
	shrink()
	update()

func update() -> void:
	visible = item != null
	if not visible:
		return
	icon_rect.texture = await item.icon.get_texture()
	name_lbl.text = item.name

func clear() -> void:
	item = null
	update()

func grow() -> void:
	icon_rect.custom_minimum_size = Vector2(GROW_SIZE, GROW_SIZE)

func shrink() -> void:
	icon_rect.custom_minimum_size = Vector2(NORMAL_SIZE, NORMAL_SIZE)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			chosen.emit(item)

func _on_mouse_entered() -> void:
	grow()

func _on_mouse_exited() -> void:
	shrink()
