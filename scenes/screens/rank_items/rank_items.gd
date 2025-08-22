extends Control

@export var start_btn: Button
@export var choices_menu: HBoxContainer
@export var choice_a: Choice
@export var choice_b: Choice

var processed_pairs: Array[Array]
var can_select: bool

signal item_selected(item: Item)

func _ready() -> void:
	start_btn.show()
	choices_menu.hide()

func _on_back_btn_pressed() -> void:
	ScreenManager.go_back()

func _on_start_btn_pressed() -> void:
	start_btn.hide()
	choices_menu.show()
	# Shuffle items into starting array
	var items: Array[Item] = Global.ranking.items.values()
	items.shuffle()
	# Loop until ranking is complete
	while true:
		var swapped: bool = false
		for i in range(items.size()-1):
			# Go through each pair
			var a: Item = items[i]
			var b: Item = items[i+1]
			# Ask the user which they prefer, to determine whether to swap
			if await should_swap(a, b):
				# Swap items
				items[i] = b
				items[i+1] = a
				swapped = true
				# Swapped pair has been processed
				processed_pairs.append([b, a])
			else:
				# Don't swap items
				# Unswapped pair has been processed
				processed_pairs.append([a, b])
		# If no swaps were made, ranking is complete
		if not swapped:
			break
	# Set the rank of each item, based on their index in the sorted array
	for i in range(items.size()):
		items[i].rank = i+1
	# Save the ranking
	Global.ranking.save()
	# Return to View Ranking screen
	ScreenManager.go_back()

func should_swap(a: Item, b: Item) -> bool:
	# Don't swap, if pair has already been processed
	if processed_pairs.has([a, b]):
		return false
	# Display choices
	choice_a.item = a
	choice_b.item = b
	await choice_a.fade_in()
	await choice_b.fade_in()
	# Wait for user to select an item
	can_select = true
	var item: Item = await item_selected
	# Swap if selected item is B
	return item == b

func _on_choice_a_pressed() -> void:
	if not can_select:
		return
	can_select = false
	choice_b.not_selected()
	await choice_a.selected()
	item_selected.emit(choice_a.item)

func _on_choice_b_pressed() -> void:
	if not can_select:
		return
	can_select = false
	choice_a.not_selected()
	await choice_b.selected()
	item_selected.emit(choice_b.item)
