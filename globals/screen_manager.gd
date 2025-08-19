extends Node

enum Screen { MAIN, EDIT_RANKING, ADD_ITEM, VIEW_RANKING, RANK_ITEMS }

const UIDS: Dictionary = {
	Screen.MAIN: "uid://bqr8c27bfa1fq",
	Screen.EDIT_RANKING: "uid://bv3hqf26ln738",
	Screen.ADD_ITEM: "uid://d2n67iox5s2gc",
	Screen.VIEW_RANKING: "uid://yhdud82o8og3",
	Screen.RANK_ITEMS: "uid://0amivtowicwr"
}

# MAIN - []
# VIEW - [MAIN]
# EDIT - [MAIN, VIEW]
# VIEW - [MAIN]

# MAIN - []
# EDIT - [MAIN]
# VIEW - [MAIN]

var current_screen: Screen
var history: Array[Screen]

func switch_to(screen: Screen) -> void:
	get_tree().change_scene_to_file(UIDS.get(screen))
	current_screen = screen

func go_to(screen: Screen) -> void:
	history.append(current_screen)
	switch_to(screen)

func go_back() -> void:
	switch_to(history.pop_back())

func return_to(screen: Screen) -> void:
	switch_to(screen)
	history.clear()
