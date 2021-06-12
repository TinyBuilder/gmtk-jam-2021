extends RigidBody2D

export (int) var run_speed = 500
export (int) var max_force = 1000
export (int) var max_speed = 100
export (int) var jump_speed = -400
export (int) var gravity = 1200


var force = Vector2()
var jumping = false

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	
	force.x = 0
	
	if right:
		print('right')
		force.x += run_speed
	if left:
		print('left')
		force.x -= run_speed
		
	if abs(force.x) > max_force:
		force.x = (force.x / abs(force.x)) * max_force

func _process(delta):
	get_input()

func _integrate_forces(state):

	add_central_force(force)
	add_central_force(get_applied_force().normalized() * -250)
	
	if abs(get_applied_force().x) > max_force:
		set_applied_force(Vector2(get_applied_force().x / abs(get_applied_force().x) * run_speed, get_applied_force().y))
	
	if abs(get_linear_velocity().x) > max_speed or abs(get_linear_velocity().y) > max_speed:
		var new_speed = get_linear_velocity().normalized()
		new_speed *= max_speed
		set_linear_velocity(new_speed)
