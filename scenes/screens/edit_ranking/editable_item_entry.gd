class_name EditableItemEntry extends PanelContainer

@export var icon_rect: TextureRect
@export var name_lbl: Label
@export var type_lbl: Label

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture = await icon.get_texture()

signal remove_item

func _on_remove_btn_pressed() -> void:
	remove_item.emit()
