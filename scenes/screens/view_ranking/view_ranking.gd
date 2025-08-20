extends Control

const ITEM_ENTRY = preload("res://scenes/screens/view_ranking/item_entry.tscn")

@export var name_lbl: Label
@export var item_entries: VBoxContainer
@export var no_items_lbl: Label

func _ready() -> void:
	name_lbl.text = Global.ranking.name
	update_item_entires()

func _on_back_btn_pressed() -> void:
	ScreenManager.go_back()

func _on_edit_btn_pressed() -> void:
	ScreenManager.go_to(ScreenManager.Screen.EDIT_RANKING)

func update_item_entires() -> void:
	for entry in item_entries.get_children():
		item_entries.remove_child(entry)
		entry.queue_free()
	var items: Array[Item] = Global.ranking.get_items_ranked()
	for item: Item in items:
		var entry: ItemEntry = ITEM_ENTRY.instantiate()
		entry.rank = item.rank
		entry.icon = item.icon
		entry.name_lbl.text = item.name
		entry.type_lbl.text = item.type
		item_entries.add_child(entry)
	no_items_lbl.visible = items.is_empty()

func _on_rank_btn_pressed() -> void:
	ScreenManager.go_to(ScreenManager.Screen.RANK_ITEMS)
