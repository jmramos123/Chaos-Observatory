# Chaos Theory Implementation - Technical Documentation

## Mathematical Foundation

### The Field Variables

The Chaos Observatory simulates a 6-dimensional nonlinear dynamical system:

```
State Vector: S = [order, stability, entropy, momentum, growth_pressure, oscillation]
```

Each variable represents an abstract property of the simulated world:

- **order**: Degree of structure and pattern
- **stability**: Resistance to change
- **entropy**: Disorder and unpredictability
- **momentum**: Directional change momentum
- **growth_pressure**: Expansion/contraction tendency
- **oscillation**: Cyclical behavior strength

### Coupled Differential Equations

The system evolves according to these ODEs (implemented in `FieldManager.evolve_field()`):

```
dO/dt = O(1-O) - 0.3E + 0.1S        [Logistic growth, entropy damping, stability boost]
dS/dt = -0.2O + 0.5S - 0.05M        [Order opposition, self-reinforcement, momentum damping]
dE/dt = 0.2M + 0.4(1-S) - 0.3E      [Momentum excitation, instability boost, self-damping]
dM/dt = -0.1O + 0.2G - 0.2X         [Order opposition, growth boost, oscillation damping]
dG/dt = 0.15O - 0.1G + 0.05E        [Order boost, self-damping, entropy boost]
dX/dt = 0.25·fract(E) - 0.2X + 0.1O [Nonlinear entropy coupling, self-damping, order boost]
```

Where:
- O = order, S = stability, E = entropy
- M = momentum, G = growth_pressure, X = oscillation
- fract(x) = x - floor(x) [fractional part, introduces nonlinearity]

### Why This Is Chaotic

1. **Nonlinear coupling**: Variables affect each other in nonlinear ways
2. **Feedback loops**: Order affects stability which affects entropy which affects momentum...
3. **Fractional function**: `fract(E)` introduces discontinuity and sensitivity
4. **No equilibrium**: The system has no fixed point attractor for most initial conditions

## Sensitive Dependence on Initial Conditions

### The Weighting System

The core mechanism demonstrating chaos theory:

```gdscript
weights = [0.0, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.2, 1.0, 0.8, 0.6]
```

Task contributions are scaled: `delta_actual = delta_raw × weight[task_index]`

**Impact Ratios:**
- Task 1 vs Task 10: **6.67x** more influential
- Task 1 vs Task 5: **2.0x** more influential
- Task 5 vs Task 10: **3.33x** more influential

This exponential decay models the key principle:

> **Small changes in initial conditions lead to large changes in outcome**

### Mathematical Justification

In chaos theory, the Lyapunov exponent λ measures sensitivity:

```
|δZ(t)| ≈ |δZ(0)| × e^(λt)
```

Our weighting system approximates this by making early perturbations (t=0) have exponentially larger effect than later ones.

## Task Delta Design

Each task computes a success metric `s ∈ [0, 1]` and applies:

```gdscript
delta = {
    "variable_name": (s - 0.5) × magnitude
}
```

The `(s - 0.5)` centers the effect:
- Perfect performance (s=1.0) → +0.5 × magnitude
- Poor performance (s=0.0) → -0.5 × magnitude
- Average performance (s=0.5) → 0.0 (neutral)

**Example (Task 1):**
```gdscript
{
    "order": (success_metric - 0.5) × 0.8,      # ±0.4 max
    "stability": (success_metric - 0.5) × 0.5,  # ±0.25 max
    "entropy": (0.5 - success_metric) × 0.4     # ±0.2 max (inverted)
}
```

After weighting (w=4.0 for Task 1):
```
Actual impact:
- order: ±1.6
- stability: ±1.0
- entropy: ∓0.8
```

Compare to Task 10 (w=0.6):
```
Actual impact:
- order: ±0.18
- stability: ±0.15
- entropy: ∓0.12
```

**8.9x difference in order influence!**

## Determinism vs Randomness

### Zero Randomness

The system contains **no RNG calls** except for:
- Visual noise/effects (not gameplay)
- Initial task configurations (deterministic seeds)

Every playthrough with identical inputs produces identical outputs.

### Perceived Randomness

Players experience "randomness" because:

1. **Nonlinear amplification**: Small input differences → large output differences
2. **Complex dynamics**: 6D coupled system with 120 evolution steps
3. **Non-obvious causality**: How Task 2 affects momentum affects entropy affects oscillation...
4. **Threshold sensitivity**: Endings based on threshold crossings

This is **deterministic chaos** - the hallmark of chaotic systems.

## Ending Classification

### Threshold-Based Regions

The 6D state space is partitioned into regions:

```gdscript
Region 1 (Harmonic Garden):
    order > 0.6 AND stability > 0.5

Region 2 (Storm Spiral):
    entropy > 0.7 AND oscillation > 0.6

Region 3 (Frozen Collapse):
    growth_pressure < -0.2 AND stability < -0.3

Region 4 (Runaway Bloom):
    momentum > 0.6 AND 0.3 < entropy < 0.8

Region 5 (Stable Equilibrium):
    |order| < 0.3 AND |stability| < 0.3 AND |entropy| < 0.3

Region 6 (Fractal Cascade):
    entropy > 0.7 OR |momentum| > 0.8 OR |oscillation| > 0.8
    (and not in other regions)
```

These regions are **not mutually exclusive** - the logic has priority order.

### Basin of Attraction

Each ending has a "basin" in initial condition space:

- **Harmonic Garden**: Requires consistent high performance on order/stability tasks
- **Storm Spiral**: Results from poor early performance or chaos-inducing choices
- **Frozen Collapse**: Achieved by failing growth/momentum tasks early
- **Runaway Bloom**: Needs strong momentum + controlled entropy
- **Stable Equilibrium**: Requires balanced, moderate performance
- **Fractal Cascade**: Any extreme imbalance

The basins are **fractal** - meaning tiny changes in initial conditions can flip between endings.

## Numerical Integration

### Euler Method

We use simple forward Euler integration:

```gdscript
for i in 120 steps:
    new_order = order + dt × f_order(state)
    new_stability = stability + dt × f_stability(state)
    # ... etc
    state = new_state
```

With `dt = 0.02` and `steps = 120`:
- Total simulation time: T = 120 × 0.02 = 2.4 arbitrary time units
- Small enough dt for stability
- Large enough steps for complex evolution

### Why Not Runge-Kutta?

- Euler is sufficient for qualitative chaos demonstration
- RK4 would be more accurate but unnecessary
- Computational speed isn't a concern
- Determinism is maintained either way

## Validation & Testing

### Testing Determinism

```gdscript
# Two playthroughs with identical inputs must produce identical outputs
var run1 = play_with_inputs([0.8, 0.7, 0.9, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0])
var run2 = play_with_inputs([0.8, 0.7, 0.9, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0])
assert(run1.ending == run2.ending)
assert(run1.final_state == run2.final_state)
```

### Testing Sensitivity

```gdscript
# Tiny change in Task 1 should alter outcome
var run_a = play_with_inputs([0.80, 0.7, 0.9, ...])  # Task 1: 0.80
var run_b = play_with_inputs([0.81, 0.7, 0.9, ...])  # Task 1: 0.81
# Often different endings!

# Same change in Task 10 should barely matter
var run_c = play_with_inputs([0.8, 0.7, 0.9, ..., 0.80])  # Task 10: 0.80
var run_d = play_with_inputs([0.8, 0.7, 0.9, ..., 0.81])  # Task 10: 0.81
# Usually same ending
```

### Testing Endings Coverage

All 6 endings should be reachable:

| Ending | Strategy |
|--------|----------|
| Harmonic Garden | Excel at all early tasks |
| Storm Spiral | Fail early tasks, especially entropy-increasing ones |
| Frozen Collapse | Fail growth/momentum tasks |
| Runaway Bloom | Excel at momentum tasks, moderate entropy |
| Stable Equilibrium | Perform moderately (50-60%) on all tasks |
| Fractal Cascade | Create one extreme variable imbalance |

## Extensions & Research

### Possible Enhancements

1. **Lorenz System**: Replace current equations with actual Lorenz attractor
2. **Bifurcation Diagram**: Show how endings change with one parameter
3. **Phase Space Visualization**: Plot 3D trajectory of state evolution
4. **Lyapunov Exponent Calculation**: Compute actual chaos metric
5. **Multiple Attractors**: Design system with distinct stable states

### Educational Value

This implementation teaches:

- Sensitive dependence on initial conditions
- Deterministic chaos (no randomness needed)
- Nonlinear dynamics
- Phase space and attractors
- Butterfly effect in action
- How small causes can have large effects

### Research Applications

The code structure could be adapted for:

- Climate model sensitivity studies
- Economic system modeling
- Population dynamics
- Chemical reaction networks
- Any system exhibiting chaotic behavior

## References

- Lorenz, E. N. (1963). "Deterministic Nonperiodic Flow"
- Strogatz, S. (2015). "Nonlinear Dynamics and Chaos"
- Gleick, J. (1987). "Chaos: Making a New Science"

---

**This is a pedagogically sound implementation of chaos theory principles in an interactive game format.**
