class_name RankingEntry extends Button

var ranking_icon: Icon:
	set(new_icon):
		ranking_icon = new_icon
		icon = await ranking_icon.get_texture()
