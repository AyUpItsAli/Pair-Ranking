extends Node

var client_id: String
var client_secret: String
var token: String

var search_request: HTTPRequest

signal search_completed(data: Dictionary)

func _ready() -> void:
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
	# Cancel previous request (if one exists)
	if search_request:
		search_request.cancel_request()
		search_request.queue_free()
	# Refresh token (if requested by caller)
	if new_token:
		await refresh_token()
	# Create a new search request
	search_request = HTTPRequest.new()
	search_request.request_completed.connect(
		_on_search_request_completed.bind(query, type, limit, new_token)
	)
	add_child(search_request)
	# Send search request 
	var error: Error = search_request.request(
		"https://api.spotify.com/v1/search?q=%s&type=%s&limit=%s" % [query, type, limit],
		["Authorization: Bearer %s" % token],
		HTTPClient.METHOD_GET
	)
	if error != OK:
		push_error("Error in Spotify search request: %s" % error)

func _on_search_request_completed(
	result: int, response: int, _headers: PackedStringArray, body: PackedByteArray,
	query: String, type: String, limit: int, new_token: bool
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error in Spotify search result: %s" % result)
		return
	# If response was unsuccessful
	if response != 200:
		if new_token:
			# Display error if a new token was used
			push_error("Error in Spotify search response: %s" % response)
			return
		else:
			# Otherwise, try again with a new token
			search(query, type, limit, true)
			return
	var data: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	search_completed.emit(data)

func get_album_tracks(album_id: String, new_token: bool = false) -> Dictionary:
	if new_token:
		await refresh_token()
	var result: Array = await Http.simple_request(
		"https://api.spotify.com/v1/albums/%s/tracks" % album_id,
		["Authorization: Bearer %s" % token],
		HTTPClient.METHOD_GET
	)
	if result.is_empty():
		if new_token:
			return {}
		else:
			return await get_album_tracks(album_id, true)
	var body: PackedByteArray = result[3]
	return JSON.parse_string(body.get_string_from_utf8())
