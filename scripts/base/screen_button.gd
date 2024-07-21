class_name ScreenButton
extends TextureButton

signal clicked(button)

func _on_pressed():
	print("clicked")
	clicked.emit(self)
