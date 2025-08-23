extends Node

var document: JavaScriptObject = JavaScriptBridge.get_interface("document")
var console: JavaScriptObject = JavaScriptBridge.get_interface("console")
var array: JavaScriptObject = JavaScriptBridge.get_interface("Array")

var file_input: JavaScriptObject
var file_input_callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_file_input_change)
var file_reader_callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_file_reader_load)

signal file_loaded(buffer: PackedByteArray)
signal files_loaded(buffers: Array[PackedByteArray])

func _ready() -> void:
	if not OS.has_feature("web"):
		return
	file_input = document.createElement("input")
	file_input.type = "file"
	file_input.onchange = file_input_callback

func get_files(accept: String, multiple: bool) -> Array[PackedByteArray]:
	file_input.accept = accept
	file_input.multiple = multiple
	file_input.click()
	return await files_loaded

func _on_file_input_change(_args: Array) -> void:
	var buffers: Array[PackedByteArray]
	for i in range(file_input.files.length):
		var file: JavaScriptObject = file_input.files[i]
		var file_reader = JavaScriptBridge.create_object("FileReader")
		file_reader.onload = file_reader_callback
		file_reader.readAsArrayBuffer(file)
		buffers.append(await file_loaded)
	files_loaded.emit(buffers)

func _on_file_reader_load(args: Array) -> void:
	var result: JavaScriptObject = args[0].target.result
	if not JavaScriptBridge.is_js_buffer(result):
		return
	file_loaded.emit(JavaScriptBridge.js_buffer_to_packed_byte_array(result))
