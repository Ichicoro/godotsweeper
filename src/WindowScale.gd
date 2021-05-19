extends Node

func _ready() -> void:
#    get_tree().get_root().connect("size_changed", self, "_handle_resize")
    OS.set_window_size(get_viewport().get_visible_rect().size * OS.get_screen_scale())

#func _handle_resize() -> void:
#    pass
