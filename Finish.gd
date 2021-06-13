extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Finish_body_entered(body):
	if body.get_name() == "Boulder" :
		body.add_central_force(Vector2(0, -10000000))
		get_parent().get_child(get_parent().get_child_count()-1).start()
