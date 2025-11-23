# 🌌 Chaos Observatory

> *A deterministic chaos theory puzzle game where your early choices shape reality itself.*


## 🎮 About The Game

**Chaos Observatory** is a puzzle game that demonstrates real chaos theory principles through gameplay. You're a technician managing an unstable quantum field through 10 increasingly complex calibration tasks. 

**The twist?** Your early actions matter exponentially more than later ones - just like real chaotic systems where initial conditions determine everything.

### Key Features

- 🎯 **Zero Randomness** - Completely deterministic outcomes
- ⚖️ **Exponential Weighting** - Early tasks have 4× more impact than later ones
- 🌐 **6 Unique Endings** - Based on how you balance chaos metrics
- 🧪 **Real Physics** - Coupled differential equations drive the field evolution
- 🎨 **Sci-Fi Aesthetics** - Portal-inspired transitions and UI

---

## 🕹️ How To Play

### Gameplay Loop

1. **Complete 10 Tasks** - Each task tests different skills: alignment, frequency tuning, temperature balance, particle sorting, and more
2. **Manage 6 Chaos Metrics** - Your performance affects: Order, Stability, Entropy, Momentum, Growth Pressure, and Oscillation
3. **Watch Evolution** - After all tasks, the field evolves based on accumulated metrics
4. **Discover Your Ending** - Reach one of 6 distinct outcomes

### Controls

- **Mouse/Click** - Interact with buttons, sliders, and draggable objects
- **Drag & Drop** - Some tasks require precise positioning
- **Sliders** - Adjust values to match targets
- **Timed Challenges** - Complete each task within 8-15 seconds

---

## 🌟 The Six Endings

Your choices throughout the 10 tasks determine which ending you'll reach. Each ending represents a different state of the chaos field:

### 🟢 Stable Equilibrium
**How to get it:** Perform consistently well across all tasks without extremes in any direction.

**What happens:** The field achieves perfect balance. All forces harmonize into a peaceful, sustainable state. Particles arrange in a gentle, pulsing grid pattern.

**Chaos Metrics:** All metrics remain in moderate ranges (Order < 3, Stability < 3.5, Entropy < 2, Momentum < 0.7)

---

### 🔷 Harmonic Garden
**How to get it:** Excel at precision tasks (Task 1, 4, 5, 8) while maintaining stability (Task 3, 6, 7, 8, 10).

**What happens:** The field crystallizes into perfect order. Hexagonal patterns emerge, creating a pristine mathematical paradise where every element knows its place.

**Chaos Metrics:** High Order (>4.0) + High Stability (>5.0)

---

### 🌀 Fractal Cascade
**How to get it:** Create extreme imbalances - fail tasks dramatically or push any metric to absolute extremes.

**What happens:** The field fractures into infinite recursive complexity. Self-similar patterns branch endlessly in a beautiful but chaotic mathematical explosion.

**Chaos Metrics:** Any metric reaches extreme values (Order >5, Stability >6, Entropy >2.5, Momentum >0.4, or Oscillation >0.6)

---

### 🌪️ Storm Spiral
**How to get it:** Fail most tasks (building positive entropy) while excelling at Task 2 (oscillation).

**What happens:** Chaos takes physical form. The field becomes a maelstrom of competing energies, particles spiral wildly in a dance of entropy and oscillation.

**Chaos Metrics:** High Positive Entropy (>2.0) + Positive Oscillation (>0.3)

---

### ❄️ Frozen Collapse
**How to get it:** Fail consistently throughout, especially early high-weight tasks (Task 1-4).

**What happens:** The field succumbs to entropy. All motion ceases, energy drains away, and everything collapses slowly into a cold, silent stasis.

**Chaos Metrics:** Negative Growth Pressure (<-0.5) + Low Stability (<-2.0)

---

### 🎆 Runaway Bloom
**How to get it:** Complete Task 7 and 10 quickly (momentum) while having mixed performance (moderate entropy).

**What happens:** The field explodes into uncontrolled growth. Energy cascades without limit in a beautiful but destructive explosion of rainbow particles.

**Chaos Metrics:** High Momentum (>0.35) + Entropy between -1.5 and 2.5

---

## 🧪 Understanding Chaos Metrics

The game tracks 6 interconnected variables that determine your ending:

| Metric | Increased By | Decreased By |
|--------|-------------|--------------|
| **Order** | Precision in alignment tasks (1, 5, 8, 10) | Random/scattered actions |
| **Stability** | Smooth, controlled adjustments (2, 3, 6) | Rapid changes, overshooting |
| **Entropy** | Failures, time running out | Perfect task completion |
| **Momentum** | Fast completion, consecutive successes (3, 4, 7) | Hesitation, slow performance |
| **Growth Pressure** | Aggressive actions, overshooting targets | Minimal adjustments |
| **Oscillation** | Back-and-forth corrections (3, 6, 9) | Direct, steady approaches |

### 📊 Exponential Task Weighting

**This is crucial:** Early tasks have exponentially more impact!

- **Task 1:** 4.0× multiplier (400% impact!)
- **Task 2:** 2.5× multiplier
- **Task 3:** 1.8× multiplier
- **Task 4:** 1.5× multiplier
- **Task 5:** 1.2× multiplier
- **Task 6-7:** 1.0× multiplier (baseline)
- **Task 8:** 0.9× multiplier
- **Task 9:** 0.75× multiplier
- **Task 10:** 0.6× multiplier (only 60% impact)

**What this means:** Failing Task 1 is equivalent to failing Tasks 8, 9, and 10 combined. Your opening moves matter more than your ending!

---

## 🎯 Strategy Tips

### To Achieve Stable Equilibrium
- Aim for "good enough" on all tasks
- Don't over-correct or rush
- Balance is key - avoid extremes

### To Achieve Harmonic Garden
- Perfect Tasks 1, 2, 5, and 8 (alignment & precision)
- Take your time on measurements
- Minimize oscillation

### To Achieve Storm Spiral
- Be inconsistent - alternate between good and poor performance
- Focus chaos on later tasks (less weighted)
- Create oscillation through corrections

### To Achieve Frozen Collapse
- Intentionally fail early tasks
- Let timers run out
- Avoid building momentum

### To Achieve Runaway Bloom
- Rush through successfully
- Build momentum on Tasks 3, 4, 7
- Accept some entropy from speed

### To Achieve Fractal Cascade
- Create extreme results
- Either perfect everything or fail dramatically
- Push any metric to extremes (>85 or <15)

---

## 🛠️ Technical Details

### Built With
- **Engine:** Godot 4.x
- **Language:** GDScript
- **Architecture:** Autoload singleton pattern for state management
- **Physics:** Coupled differential equations for field evolution


### Core Systems

**FieldManager (Autoload)**
- Tracks 6 chaos metrics globally
- Applies exponential task weighting
- Runs nonlinear evolution simulation
- Determines ending based on threshold logic

**Task System**
- Each task is self-contained with unique mechanics
- Performance scored 0-100%
- Metrics delta calculated based on player actions
- Weighted contribution to global field state

**Evolution System**
- 5-second simulation after all tasks complete
- Coupled differential equations model field dynamics
- Visual feedback shows state changes
- Deterministic outcome based on accumulated metrics

---

## 🎓 Educational Value

This game demonstrates several chaos theory concepts:

1. **Butterfly Effect** - Small initial differences (Task 1 performance) lead to dramatically different outcomes
2. **Deterministic Chaos** - No randomness, yet outcomes feel unpredictable
3. **Phase Space** - 6-dimensional state space determines system trajectory
4. **Attractors** - Each ending represents a basin of attraction
5. **Nonlinear Dynamics** - Metrics interact and evolve through coupled equations
6. **Sensitivity to Initial Conditions** - Exponential weighting demonstrates this principle

---

## 📜 License

This project is not licensed.

---


### 🌌 *Every action matters. Choose wisely.* 🌌

Made with ❤️ using Godot Engine

