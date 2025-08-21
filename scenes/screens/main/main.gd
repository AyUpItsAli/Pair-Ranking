extends Control

const RANKING_ENTRY = preload("res://scenes/screens/main/ranking_entry.tscn")

@export var new_ranking_btn: BaseButton
@export var new_ranking_menu: PanelContainer
@export var ranking_entries: VBoxContainer
@export var no_rankings_lbl: Label

func _ready() -> void:
	Global.ranking = null
	new_ranking_btn.show()
	new_ranking_menu.hide()
	update_ranking_entires()

func _on_new_ranking_btn_pressed() -> void:
	new_ranking_btn.hide()
	new_ranking_menu.show()

func _on_album_ranking_btn_pressed() -> void:
	# TODO: Create from Album
	pass

func _on_empty_ranking_btn_pressed() -> void:
	Global.ranking = Ranking.create_untitled_ranking()
	ScreenManager.go_to(ScreenManager.Screen.EDIT_RANKING)

func update_ranking_entires() -> void:
	for entry in ranking_entries.get_children():
		ranking_entries.remove_child(entry)
		entry.queue_free()
	var rankings: Array[Ranking] = Ranking.get_rankings()
	for ranking: Ranking in rankings:
		var entry: RankingEntry = RANKING_ENTRY.instantiate()
		entry.text = ranking.name
		entry.ranking_icon = ranking.icon
		entry.pressed.connect(view_ranking.bind(ranking))
		ranking_entries.add_child(entry)
	no_rankings_lbl.visible = rankings.is_empty()

func view_ranking(ranking: Ranking) -> void:
	Global.ranking = ranking
	ScreenManager.go_to(ScreenManager.Screen.VIEW_RANKING)
