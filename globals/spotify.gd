extends Node

var client_id: String
var client_secret: String
var token: String

func _ready() -> void:
	var config := ConfigFile.new()
	var error: Error = config.load("res://spotify.cfg")
	if error != OK:
		push_error("Error loading Spotify config: %s" % error)
		return
	client_id = config.get_value("API", "client_id")
	client_secret = config.get_value("API", "client_secret")

func refresh_token() -> void:
	var result: Array = await Http.request(
		"https://accounts.spotify.com/api/token",
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		"grant_type=client_credentials&client_id=%s&client_secret=%s" % [client_id, client_secret]
	)
	if result[1] != 200:
		push_error("Error requesting Spotify access token: %s" % result[1])
		return
	var body: PackedByteArray = result[3]
	token = JSON.parse_string(body.get_string_from_utf8()).get("access_token")

func search(query: String, new_token: bool = false) -> Dictionary:
	if new_token:
		await refresh_token()
	var result: Array = await Http.request(
		"https://api.spotify.com/v1/search?q=%s" % query,
		["Authorization: Bearer %s" % token],
		HTTPClient.METHOD_GET
	)
	if result[1] != 200:
		if new_token:
			push_error("Error in Spotify search response: %s" % result[1])
			return {}
		else:
			return await search(query, true)
	var body: PackedByteArray = result[3]
	return JSON.parse_string(body.get_string_from_utf8())
