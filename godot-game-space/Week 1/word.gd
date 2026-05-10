extends Node2D

func _ready() -> void:
	$UI.visible = true

func _on_option_button_pressed():
	$Option.toggle_option()
