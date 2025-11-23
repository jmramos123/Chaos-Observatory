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
	
	# Check for extreme imbalances first (Fractal Cascade)
	# This represents total system breakdown into chaos
	if abs(o) > 7.0 or abs(s) > 8.0 or abs(e) > 6.0 or abs(m) > 1.2 or abs(x) > 1.8:
		return "fractal_cascade"
	
	# Harmonic Garden - high order AND high stability (precision + control)
	# Requires good performance on alignment tasks (1,4,5,8) + stability tasks (3,6,7,8,10)
	if o > 4.0 and s > 5.0:
		return "harmonic_garden"
	
	# Storm Spiral - high positive entropy with high oscillation (chaos + turbulence)
	# Achieved by failing tasks while being good at Task2 (oscillation)
	if e > 2.0 and x > 1.0:
		return "storm_spiral"
	
	# Runaway Bloom - high momentum with moderate positive entropy (uncontrolled growth)
	# Requires fast completion of Task7/10 while having some failures
	if m > 0.8 and e > -1.0 and e < 3.0:
		return "runaway_bloom"
	
	# Frozen Collapse - low growth pressure AND low stability (energy drain + instability)
	# Requires consistent poor performance leading to negative evolution
	if g < -0.5 and s < -2.0:
		return "frozen_collapse"
	
	# Stable Equilibrium - all metrics in moderate range (balanced performance)
	# The "good enough" ending - not perfect, not terrible
	if abs(o) < 3.0 and abs(s) < 3.5 and abs(e) < 2.0 and abs(m) < 0.7 and abs(g) < 1.5 and abs(x) < 1.0:
		return "stable_equilibrium"
	
	# Default fallback - Stable Equilibrium for any unmatched state
	return "stable_equilibrium"

# Helper for fractional part
func fract(v: float) -> float:
	return v - floor(v)
