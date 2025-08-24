extends Node

var document: JavaScriptObject = JavaScriptBridge.get_interface("document")

var file_input: JavaScriptObject
var file_input_callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_file_input_change)
var file_reader_callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_file_reader_load)

signal files_uploaded(uploads: Array[Upload])
signal file_loaded(buffer: PackedByteArray)

func _ready() -> void:
	if not OS.has_feature("web"):
		return
	file_input = document.createElement("input")
	file_input.type = "file"
	file_input.onchange = file_input_callback

func upload_file(accept: String) -> Upload:
	if not OS.has_feature("web"):
		return null
	var uploads: Array[Upload] = await upload_files(accept, false)
	if uploads.is_empty():
		return null
	return uploads.front()

func upload_files(accept: String, multiple: bool = true) -> Array[Upload]:
	if not OS.has_feature("web"):
		return []
	file_input.accept = accept
	file_input.multiple = multiple
	file_input.click()
	return await files_uploaded

func _on_file_input_change(_args: Array) -> void:
	var uploads: Array[Upload]
	for i in range(file_input.files.length):
		var file: JavaScriptObject = file_input.files[i]
		var upload := Upload.new()
		upload.type = file.type
		var file_reader = JavaScriptBridge.create_object("FileReader")
		file_reader.onload = file_reader_callback
		file_reader.readAsArrayBuffer(file)
		upload.buffer = await file_loaded
		uploads.append(upload)
	files_uploaded.emit(uploads)

func _on_file_reader_load(args: Array) -> void:
	var result: JavaScriptObject = args[0].target.result
	if not JavaScriptBridge.is_js_buffer(result):
		return
	file_loaded.emit(JavaScriptBridge.js_buffer_to_packed_byte_array(result))
