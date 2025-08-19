extends Control

@export var choice_a: Choice
@export var choice_b: Choice

var completed_pairs: Array[Array]

signal item_selected(item: Item)

func _ready() -> void:
	completed_pairs.clear()
	var items: Array[Item] = Global.ranking.items.values()
	items.shuffle()
	while true:
		var swapped: bool = false
		for i in range(items.size()-1):
			var a: Item = items[i]
			var b: Item = items[i+1]
			if await should_swap(a, b):
				items[i] = b
				items[i+1] = a
				swapped = true
				completed_pairs.append([b, a])
			else:
				completed_pairs.append([a, b])
		if not swapped:
			break
	# TODO: "Finish" and "Cancel" buttons
	for i in range(items.size()):
		items.get(i).rank = i+1
	ScreenManager.go_back()

func should_swap(a: Item, b: Item) -> bool:
	if completed_pairs.has([a, b]):
		return false
	choice_a.item = a
	choice_b.item = b
	choice_a.update()
	choice_b.update()
	var item: Item = await item_selected
	return item == b

func _on_choice_chosen(item: Item) -> void:
	choice_a.clear()
	choice_b.clear()
	item_selected.emit(item)
