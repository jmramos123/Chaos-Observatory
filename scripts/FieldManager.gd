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
	print("=== TASK ", task_index, " DELTA ===")
	print("Before: order=", order, " stability=", stability, " entropy=", entropy)
	
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
	
	print("After: order=", order, " stability=", stability, " entropy=", entropy)
	print("Weight: ", w, " Delta: ", delta)

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



func evolve_field(_steps: int = 120, _dt: float = 0.02) -> Dictionary:
	print("=== STARTING EVOLUTION ===")
	print("Initial state from FieldManager:")
	print("  order: ", order)
	print("  stability: ", stability)
	print("  entropy: ", entropy)
	print("  momentum: ", momentum)
	print("  growth_pressure: ", growth_pressure)
	print("  oscillation: ", oscillation)
	
	# Start with current accumulated values (no evolution needed)
	# The chaos equations were causing nan with unbounded values
	# We'll use the raw accumulated metrics directly
	var o = order
	var s = stability
	var e = entropy
	var m = momentum
	var g = order + entropy * 0.5  # Growth pressure emerges from order + entropy
	var x = oscillation
	
	print("Final state (direct metrics):")
	print("  o: ", o, " s: ", s, " e: ", e, " m: ", m, " g: ", g, " x: ", x)

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
	
	# DEBUG: Print all final values
	print("=== FINAL METRICS ===")
	print("Order: ", o)
	print("Stability: ", s)
	print("Entropy: ", e)
	print("Momentum: ", m)
	print("Growth Pressure: ", g)
	print("Oscillation: ", x)
	print("===================")
	
	# Runaway Bloom - high momentum with moderate entropy (uncontrolled growth)
	# Check FIRST among positive endings - momentum is unique indicator
	if m > 0.3 and e > -2.0 and e < 2.0:
		print("ENDING: Runaway Bloom (high momentum)")
		return "runaway_bloom"
	
	# Storm Spiral - high positive entropy with high oscillation (chaos + turbulence)
	# Check BEFORE Frozen Collapse - active chaos vs passive collapse
	# Represents turbulent energy, not stillness
	if e > 1.5 and x > 0.2:
		print("ENDING: Storm Spiral (high entropy + oscillation)")
		return "storm_spiral"
	
	# Frozen Collapse - low stability OR low growth pressure (energy drain)
	# Check AFTER Storm Spiral - this is passive collapse, not active chaos
	if s < -2.0 or g < -0.5:
		print("ENDING: Frozen Collapse (low stability or growth)")
		return "frozen_collapse"
	
	# Harmonic Garden - high order AND high stability (precision + control)
	# Check BEFORE Fractal Cascade - this is balanced excellence, not chaos
	# Requires good performance on alignment tasks (1,4,5,8) + stability tasks (3,6,7,8,10)
	if o > 3.5 and s > 4.5:
		print("ENDING: Harmonic Garden (high order + stability)")
		return "harmonic_garden"
	
	# Check for extreme imbalances (Fractal Cascade)
	# This represents total system breakdown into chaos from POSITIVE extremes
	# Checked AFTER specialized endings to avoid blocking them
	if o > 4.5 or s > 5.5 or abs(e) > 2.0:
		print("ENDING: Fractal Cascade (extreme values)")
		return "fractal_cascade"
	
	# Frozen Collapse check is now at the top (line ~120)
	# Removed duplicate to avoid confusion
	
	# Stable Equilibrium - all metrics in moderate range (balanced performance)
	# The "good enough" ending - not perfect, not terrible
	if abs(o) < 3.0 and abs(s) < 3.5 and abs(e) < 2.0 and abs(m) < 0.7 and abs(g) < 1.5 and abs(x) < 1.0:
		print("ENDING: Stable Equilibrium (all moderate)")
		return "stable_equilibrium"
	
	# Default fallback - if nothing else matches, assume stable equilibrium
	# (This handles edge cases where metrics are slightly outside ranges but not extreme)
	print("ENDING: Stable Equilibrium (default fallback)")
	return "stable_equilibrium"

# Helper for fractional part
func fract(v: float) -> float:
	return v - floor(v)
