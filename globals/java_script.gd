extends Node

var file_input: JavaScriptObject
var file_input_callback: JavaScriptObject

var file_reader: JavaScriptObject
var file_reader_callback: JavaScriptObject

signal files_uploaded(uploads: Array[Upload])
signal file_loaded(buffer: PackedByteArray)

func _ready() -> void:
	if not OS.has_feature("web"):
		return
	# File input
	var document: JavaScriptObject = JavaScriptBridge.get_interface("document")
	file_input = document.createElement("input")
	file_input.type = "file"
	file_input_callback = JavaScriptBridge.create_callback(_on_file_input_change)
	file_input.onchange = file_input_callback
	# File reader
	file_reader = JavaScriptBridge.create_object("FileReader")
	file_reader_callback = JavaScriptBridge.create_callback(_on_file_reader_load)
	file_reader.onload = file_reader_callback

func upload_files(accept: String, multiple: bool = true) -> Array[Upload]:
	if not OS.has_feature("web"):
		return []
	file_input.accept = accept
	file_input.multiple = multiple
	file_input.click()
	return await files_uploaded

func upload_file(accept: String) -> Upload:
	var uploads: Array[Upload] = await upload_files(accept, false)
	if uploads.is_empty():
		return null
	return uploads.front()

func _on_file_input_change(_args: Array) -> void:
	var uploads: Array[Upload]
	for i in range(file_input.files.length):
		var file: JavaScriptObject = file_input.files[i]
		var upload := Upload.new()
		upload.name = file.name
		upload.type = file.type
		file_reader.readAsArrayBuffer(file)
		upload.buffer = await file_loaded
		uploads.append(upload)
	# Clear the input value after uploading files
	# Ensures the event gets triggered again if the user chooses the same file
	file_input.value = ""
	files_uploaded.emit(uploads)

func _on_file_reader_load(_args: Array) -> void:
	if not JavaScriptBridge.is_js_buffer(file_reader.result):
		return
	file_loaded.emit(JavaScriptBridge.js_buffer_to_packed_byte_array(file_reader.result))
