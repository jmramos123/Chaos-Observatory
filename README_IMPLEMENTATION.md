# 🌌 CHAOS OBSERVATORY

A deterministic chaos theory game built in Godot Engine.

## 📋 What Was Built

I've implemented the complete **Chaos Observatory** game system according to your design document:

### ✅ Core Systems

1. **FieldManager (Autoload)** - `scripts/FieldManager.gd`
   - Manages 6 core variables: order, stability, entropy, momentum, growth_pressure, oscillation
   - Implements exponential task weighting (4.0× for Task 1 down to 0.6× for Task 10)
   - Deterministic nonlinear evolution system
   - Ending detection logic for 6 different outcomes

2. **Main Game Flow** - `scripts/Main.gd`
   - Manages task progression
   - Handles intro → tasks → evolution → ending flow
   - Connects all systems together

### ✅ All 10 Tasks Created

Each task is a self-contained scene with unique mechanics:

1. **Task1_AlignCrystals.gd** - Drag and drop alignment puzzle
2. **Task2_TuneResonance.gd** - Frequency slider matching
3. **Task3_BalanceTemperature.gd** - Two-sided temperature balancing
4. **Task4_SortParticles.gd** - Particle sorting counter
5. **Task5_SequenceRunes.gd** - Pattern sequence matching
6. **Task6_StabilizeBeam.gd** - Physics-based stabilization
7. **Task7_AdjustValves.gd** - Multi-valve pressure adjustment
8. **Task8_CalibrateGrid.gd** - Harmonic grid balancing
9. **Task9_ControlDiffusion.gd** - Diffusion rate control
10. **Task10_FinalAlignment.gd** - Angular alignment

Each task:
- Has a 8-15 second timer
- Calculates performance metrics
- Applies weighted deltas to Field variables
- Earlier tasks have exponentially more impact

### ✅ 6 Deterministic Endings

All ending scripts created in `scripts/endings/`:

1. **Harmonic Garden** - High order + stability
2. **Storm Spiral World** - High entropy + oscillation  
3. **Frozen Collapse** - Low growth + low stability
4. **Runaway Bloom** - High momentum + medium entropy
5. **Stable Equilibrium** - All variables balanced
6. **Fractal Cascade** - Extreme imbalances

### ✅ Supporting Systems

- **Intro.gd** - Welcome screen with theme explanation
- **Evolution.gd** - Visual evolution simulation (5 seconds)

## 🎯 Key Features Implemented

✅ **Zero randomness** - Everything is deterministic
✅ **Exponential early-task weighting** - First tasks matter dramatically more
✅ **Nonlinear field evolution** - Coupled differential equations
✅ **Multiple endings** - Based on deterministic thresholds
✅ **Modular task system** - Easy to add/modify tasks
✅ **Clean architecture** - Autoload singleton pattern

## 🚧 What You Need To Do

Since I can only edit scripts (not create visual scenes in the Godot editor), you'll need to:

### 1. Create Scene Files (.tscn)

For each script, create a matching scene:

#### Main Scene: `scenes/main/Main.tscn`
```
Control (script: Main.gd)
├── IntroPanel (Panel/Control)
│   └── VBoxContainer
│       ├── Title (Label)
│       ├── Subtitle (Label)
│       ├── Description (RichTextLabel)
│       └── StartButton (Button)
└── TaskContainer (Control)
```

#### Evolution Scene: `scenes/main/Evolution.tscn`
```
Control (script: Evolution.gd)
└── CenterContainer
    └── VBoxContainer
        ├── StatusLabel (Label)
        └── ProgressBar (ProgressBar)
```

#### Task Scenes: `scenes/tasks/Task[1-10]_*.tscn`

Each task needs:
```
Node2D (script: Task*_.gd)
├── CanvasLayer
│   └── VBoxContainer
│       ├── LabelInstructions (Label)
│       ├── LabelTimer (Label)
│       ├── LabelStatus (Label)
│       └── [Task-specific controls]
├── Timer (Timer, 1.0 second wait_time, one_shot=false)
└── [Visual elements for the task]
```

#### Ending Scenes: `scenes/endings/*.tscn`

```
Control (script: endings/*. gd)
└── VBoxContainer
    ├── Title (Label - large font)
    ├── Description (RichTextLabel - centered)
    └── RestartButton (Button - "Try Again")
```

### 2. Set Up Autoload

In Project → Project Settings → Autoload:
- Add `FieldManager` → `scripts/FieldManager.gd`

### 3. Test The System

1. Open `Main.tscn` as the main scene
2. Run the project
3. Complete tasks and observe how early tasks affect the ending
4. Test multiple playthroughs with different strategies

### 4. Polish & Visuals (Optional)

Add visual effects:
- Particle systems for evolution
- Shaders for field visualization
- Color transitions based on variables
- Audio feedback

## 🧬 How The System Works

### Task Weighting

```gdscript
weights = [0.0, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.2, 1.0, 0.8, 0.6]
```

Task 1 has **6.67x more influence** than Task 10!

### Field Evolution

Each task modifies variables, which then evolve through coupled equations:

```gdscript
order' = order × (1 - order) - 0.3 × entropy + 0.1 × stability
stability' = -0.2 × order + 0.5 × stability - 0.05 × momentum
entropy' = 0.2 × momentum + 0.4 × (1 - stability) - 0.3 × entropy
# ... and so on
```

### Ending Determination

After 120 evolution steps, the final state is checked against thresholds:

```gdscript
if order > 0.6 and stability > 0.5:
    return "harmonic_garden"
elif entropy > 0.7 and oscillation > 0.6:
    return "storm_spiral"
# ... etc
```

## 📊 Testing Different Outcomes

To see different endings:

1. **Harmonic Garden** - Perform well on early tasks, focus on order/stability
2. **Storm Spiral** - Perform poorly or chaotically on tasks
3. **Frozen Collapse** - Do badly on tasks affecting growth/stability
4. **Runaway Bloom** - Excel at momentum-focused tasks
5. **Stable Equilibrium** - Perform moderately well on all tasks
6. **Fractal Cascade** - Create extreme imbalances

## 🔧 Customization

### Add More Tasks

1. Create new script in `scripts/TaskN_Name.gd`
2. Follow the pattern of existing tasks
3. Add to `task_scenes` array in `Main.gd`

### Adjust Difficulty

Modify in each task script:
- `max_time` - How long the task lasts
- Success calculation logic
- Delta values applied to Field

### Create New Endings

1. Add condition to `determine_ending()` in FieldManager
2. Create ending script in `scripts/endings/`
3. Update `show_ending()` in Main.gd if needed

## 🎮 Architecture

```
Main Scene
    ├── Shows intro
    ├── Loads tasks sequentially
    ├── Each task emits deltas
    ├── FieldManager accumulates weighted deltas
    ├── After all tasks → Evolution visualization
    ├── FieldManager.evolve_field() runs simulation
    ├── FieldManager.determine_ending() checks thresholds
    └── Show appropriate ending scene
```

## ✨ Summary

The entire **Chaos Observatory** game logic is now complete! All scripts follow the design document:

- ✅ 10 unique tasks with varied mechanics
- ✅ Deterministic weighting system (early tasks matter most)
- ✅ Nonlinear field evolution
- ✅ 6 distinct endings based on field state
- ✅ Zero randomness (fully deterministic)
- ✅ Modular, extensible architecture

**You just need to create the scene files in Godot's editor to connect all the scripts together.**

The game is ready to play once the visual scenes are set up! 🌌
