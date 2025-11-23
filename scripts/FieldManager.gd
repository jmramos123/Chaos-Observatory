extends Node

# Chaos Observatory - Autoload

# Core Variables

var order: float = 0.0

var stability: float = 0.0

var entropy: float = 0.0

var momentum: float = 0.0

var growth_pressure: float = 0.0

var oscillation: float = 0.0

# Tasks Weights

var weights := [0.0, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.2, 1.0, 0.8, 0.6]

# Results (Debugging / Ending)

var task_contributions: Array = []

func _ready():
	reset_all()

func apply_task_delta(task_index: int, delta: Dictionary) -> void:
	var w = weights[task_index]

	# Weighted accumulation
	for key in delta.keys():
		match key:
			"order": order += delta[key] * w
			"stability": stability += delta[key] * w
			"entropy": entropy += delta[key] * w
			"momentum": momentum += delta[key] * w
			"growth_pressure": growth_pressure += delta[key] * w
			"oscillation": oscillation += delta[key] * w

	task_contributions.append({
		"task": task_index,
		"delta": delta.duplicate(),
		"weight": w
	})



func reset_all():
	order = 0.0
	stability = 0.0
	entropy = 0.0
	momentum = 0.0
	growth_pressure = 0.0
	oscillation = 0.0
	task_contributions.clear()



func evolve_field(steps: int = 120, dt: float = 0.02) -> Dictionary:
	var o = order
	var s = stability
	var e = entropy
	var m = momentum
	var g = growth_pressure
	var x = oscillation

	for i in steps:
		var new_o = o + dt * (o * (1.0 - o) - 0.3 * e + 0.1 * s)
		var new_s = s + dt * (-0.2 * o + 0.5 * s - 0.05 * m)
		var new_e = e + dt * (0.2 * m + 0.4 * (1.0 - s) - 0.3 * e)
		var new_m = m + dt * (-0.1 * o + 0.2 * g - 0.2 * x)
		var new_g = g + dt * (0.15 * o - 0.1 * g + 0.05 * e)
		var new_x = x + dt * (0.25 * fract(e) - 0.2 * x + 0.1 * o)

		o = new_o
		s = new_s
		e = new_e
		m = new_m
		g = new_g
		x = new_x

	return {
		"order": o,
		"stability": s,
		"entropy": e,
		"momentum": m,
		"growth_pressure": g,
		"oscillation": x
	}

# Determine which ending based on final field state
func determine_ending(final_state: Dictionary) -> String:
	var o = final_state["order"]
	var s = final_state["stability"]
	var e = final_state["entropy"]
	var m = final_state["momentum"]
	var g = final_state["growth_pressure"]
	var x = final_state["oscillation"]
	
	# Calculate dominance scores
	var high_order = o > 0.6
	var high_stability = s > 0.5
	var high_entropy = e > 0.7
	var high_momentum = m > 0.6
	var high_growth = g > 0.5
	var high_oscillation = x > 0.6
	
	var low_stability = s < -0.3
	var low_growth = g < -0.2
	
	# Ending logic based on combinations
	if high_order and high_stability:
		return "harmonic_garden"
	elif high_entropy and high_oscillation:
		return "storm_spiral"
	elif low_growth and low_stability:
		return "frozen_collapse"
	elif high_momentum and e > 0.3 and e < 0.8:
		return "runaway_bloom"
	elif abs(o) < 0.3 and abs(s) < 0.3 and abs(e) < 0.3:
		return "stable_equilibrium"
	elif high_entropy or abs(m) > 0.8 or abs(x) > 0.8:
		return "fractal_cascade"
	else:
		# Default balanced ending
		return "stable_equilibrium"

# Helper for fractional part
func fract(v: float) -> float:
	return v - floor(v)
