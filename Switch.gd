extends Area2D


# Declare member variables here. Examples:
export (NodePath) var Gate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Switch_body_entered(body):
	if body.name.match("RigidPlayer"):
		get_node(Gate).global_position.y += 16
