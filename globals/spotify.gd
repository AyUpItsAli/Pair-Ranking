extends Node

var http := HTTPRequest.new()

var client_id: String
var client_secret: String
var token: String

signal search_completed(results: Dictionary)

func _ready() -> void:
	add_child(http)
	var config := ConfigFile.new()
	var error: Error = config.load("res://spotify.cfg")
	if error != OK:
		push_error("Error loading Spotify config: %s" % error)
		return
	client_id = config.get_value("API", "client_id")
	client_secret = config.get_value("API", "client_secret")
	refresh_token()

func refresh_token() -> void:
	var result: Array = await Http.simple_request(
		"https://accounts.spotify.com/api/token",
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		"grant_type=client_credentials&client_id=%s&client_secret=%s" % [client_id, client_secret]
	)
	if result.is_empty():
		return
	var body: PackedByteArray = result[3]
	token = JSON.parse_string(body.get_string_from_utf8()).get("access_token")

func search(query: String, type: String, limit: int = 20, new_token: bool = false) -> void:
	if new_token:
		await refresh_token()
	http.cancel_request()
	print("Cancelled")
	var error: Error = http.request(
		"https://api.spotify.com/v1/search?q=%s&type=%s&limit=%s" % [query, type, limit],
		["Authorization: Bearer %s" % token],
		HTTPClient.METHOD_GET
	)
	print("Requested")
	if error != OK:
		push_error("Error in Spotify search request: %s" % error)
		return
	var result: Array = await http.request_completed
	print(result[0])
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		push_error("Error in Spotify search result: %s" % result[0])
		return
	if result[1] != 200:
		if new_token:
			push_error("Error in Spotify search response: %s" % result[1])
			return
		else:
			search(query, type, limit, true)
			return
	var body: PackedByteArray = result[3]
	var results: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	search_completed.emit(results)
