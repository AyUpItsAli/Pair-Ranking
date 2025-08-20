extends Control

const ICON_ENTRY = preload("res://scenes/screens/edit_ranking/icon_entry.tscn")
const ITEM_ENTRY = preload("res://scenes/screens/edit_ranking/editable_item_entry.tscn")

@export var icon_selector: IconSelector
@export var icon_entries: HBoxContainer
@export var name_edit: LineEdit
@export var item_entries: VBoxContainer
@export var no_items_lbl: Label

func _ready() -> void:
	name_edit.text = Global.ranking.name
	icon_selector.icon = Global.ranking.icon
	update_icon_entries()
	update_item_entires()

func _on_save_btn_pressed() -> void:
	Global.ranking.save()
	ScreenManager.go_back()

func _on_delete_btn_pressed() -> void:
	Global.ranking.delete()
	ScreenManager.return_to(ScreenManager.Screen.MAIN)

func _on_icon_selector_icon_selected(icon: Icon) -> void:
	Global.ranking.icon = icon

func update_icon_entries() -> void:
	for entry in icon_entries.get_children():
		icon_entries.remove_child(entry)
		entry.queue_free()
	for icon: Icon in Global.ranking.get_icons():
		var entry: IconEntry = ICON_ENTRY.instantiate()
		entry.icon = icon
		entry.icon_rect.pressed.connect(_on_icon_entry_selected.bind(icon))
		icon_entries.add_child(entry)

func _on_icon_entry_selected(icon: Icon) -> void:
	icon_selector.icon = icon
	Global.ranking.icon = icon

func _on_name_edit_text_changed(new_name: String) -> void:
	var new_id: String = Global.string_to_id(new_name)
	if new_id.is_empty():
		name_edit.modulate = Color.RED
		return
	name_edit.modulate = Color.WHITE
	Global.ranking.name = new_name

func _on_add_music_btn_pressed() -> void:
	ScreenManager.go_to(ScreenManager.Screen.ADD_MUSIC)

func _on_add_custom_btn_pressed() -> void:
	ScreenManager.go_to(ScreenManager.Screen.ADD_ITEM)

func update_item_entires() -> void:
	for entry in item_entries.get_children():
		item_entries.remove_child(entry)
		entry.queue_free()
	var items: Array[Item] = Global.ranking.items.values()
	for item: Item in items:
		var entry: EditableItemEntry = ITEM_ENTRY.instantiate()
		entry.icon = item.icon
		entry.name_lbl.text = item.name
		entry.type_lbl.text = item.type
		entry.remove_btn.pressed.connect(_on_item_entry_remove_item.bind(item.id))
		item_entries.add_child(entry)
	no_items_lbl.visible = items.is_empty()

func _on_item_entry_remove_item(item_id: String) -> void:
	Global.ranking.remove_item(item_id)
	update_icon_entries()
	update_item_entires()
