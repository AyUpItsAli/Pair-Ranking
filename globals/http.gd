extends Node

func simple_request(url: String, headers: PackedStringArray = [], method: HTTPClient.Method = HTTPClient.Method.METHOD_GET, data: String = "") -> Array:
	var http := HTTPRequest.new()
	add_child(http)
	var error: Error = http.request(url, headers, method, data)
	if error != OK:
		push_error("Error in HTTP request: %s" % error)
		return []
	var result: Array = await http.request_completed
	http.queue_free()
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		push_error("Error in HTTP result: %s" % result[0])
		return []
	if result[1] != 200:
		push_error("Error in HTTP response: %s" % result[1])
		return []
	return result
