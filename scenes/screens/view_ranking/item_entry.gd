class_name ItemEntry extends PanelContainer

@export var rank_lbl: Label
@export var icon_rect: TextureRect
@export var name_lbl: Label

var icon: Icon:
	set(new_icon):
		icon = new_icon
		icon_rect.texture = await icon.get_texture()
var rank: int:
	set(new_rank):
		rank = new_rank
		if rank > 0:
			rank_lbl.text = "#%s" % rank
		else:
			rank_lbl.text = "--"
		match rank:
			0: rank_lbl.modulate = Color.DARK_GRAY
			1: rank_lbl.modulate = Color.GOLD
			2: rank_lbl.modulate = Color.LIGHT_STEEL_BLUE
			3: rank_lbl.modulate = Color.SANDY_BROWN
