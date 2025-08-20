extends Node

var non_word_chars := RegEx.create_from_string("[\\W_]+")
var digit_suffix := RegEx.create_from_string("\\d+$")

var ranking: Ranking

func string_to_id(string: String) -> String:
	return non_word_chars.sub(string.to_lower(), " ", true).strip_edges().replace(" ", "_")

func string_to_id_unique(string: String, existing_ids: Array[String]) -> String:
	var id: String = string_to_id(string)
	if existing_ids.has(id):
		id += "_2"
	while existing_ids.has(id):
		var num: int = int(digit_suffix.search(id).get_string())
		id = digit_suffix.sub(id, str(num+1))
	return id
