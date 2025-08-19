extends Control

@export var icon_selector: IconSelector
@export var name_edit: LineEdit
@export var type_edit: LineEdit

var item: Item

func _ready() -> void:
	item = Item.new()
	item.icon = Icon.new()
	icon_selector.icon = item.icon

func _on_back_btn_pressed() -> void:
	ScreenManager.go_back()

func _on_icon_selector_icon_selected(icon: Icon) -> void:
	item.icon = icon

func _on_name_edit_text_changed(new_name: String) -> void:
	var new_id: String = Global.string_to_id(new_name)
	if new_id.is_empty():
		name_edit.modulate = Color.RED
		return
	name_edit.modulate = Color.WHITE
	item.name = new_name

func _on_type_edit_text_changed(new_type: String) -> void:
	if new_type.is_empty():
		type_edit.modulate = Color.RED
		return
	type_edit.modulate = Color.WHITE
	item.type = new_type

func _on_add_btn_pressed() -> void:
	if item.name.is_empty():
		name_edit.modulate = Color.RED
		return
	if item.type.is_empty():
		type_edit.modulate = Color.RED
		return
	Global.ranking.add_item(item)
	ScreenManager.go_back()
