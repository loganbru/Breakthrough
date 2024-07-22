extends Node

func get_rotated_bounding_box_size(_sprite : Sprite2D) -> Vector2:
	var texture_size = _sprite.texture.get_size() * _sprite.scale
	var angle = _sprite.rotation

	# Calculate the rotated corners of the bounding box
	var half_width = texture_size.x / 2
	var half_height = texture_size.y / 2

	var rotated_corners = [
		Vector2(-half_width, -half_height).rotated(angle),
		Vector2(half_width, -half_height).rotated(angle),
		Vector2(half_width, half_height).rotated(angle),
		Vector2(-half_width, half_height).rotated(angle)
	]

	# Determine the bounding box
	var min_x = min(rotated_corners[0].x, rotated_corners[1].x, rotated_corners[2].x, rotated_corners[3].x)
	var max_x = max(rotated_corners[0].x, rotated_corners[1].x, rotated_corners[2].x, rotated_corners[3].x)
	var min_y = min(rotated_corners[0].y, rotated_corners[1].y, rotated_corners[2].y, rotated_corners[3].y)
	var max_y = max(rotated_corners[0].y, rotated_corners[1].y, rotated_corners[2].y, rotated_corners[3].y)

	# Calculate the size of the bounding box
	var bounding_box_size = Vector2(max_x - min_x, max_y - min_y)
	
	return bounding_box_size

func merge_arrays(arr1: Array, arr2: Array) -> Array:
	var merged_array = arr1.duplicate()  # Create a copy of the first array to avoid modifying the original
	merged_array.append_array(arr2)  # Append the second array to the copied first array
	return merged_array
