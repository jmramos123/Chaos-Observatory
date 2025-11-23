# Quick Scene Setup Guide

This is a step-by-step guide to create the minimal scene files needed to run Chaos Observatory.

## 1. Set Up Autoload First

**Project → Project Settings → Autoload**
- Path: `res://scripts/FieldManager.gd`
- Node Name: `FieldManager`
- Enable: ✓

## 2. Create Main Scene

File: `scenes/main/Main.tscn`

**Root Node Structure:**
```
Control [Script: Main.gd]
├── IntroPanel (Panel)
│   ├── ColorRect (optional background)
│   └── VBoxContainer (Layout mode: Center)
│       ├── Title (Label, text: "CHAOS OBSERVATORY")
│       ├── Subtitle (Label, text: "Calibration Protocol v1.0")
│       ├── Description (RichTextLabel, autowrap: true)
│       └── StartButton (Button, text: "START CALIBRATION")
└── TaskContainer (Control, anchors: full rect)
```

**Important:** Make sure node names match exactly!

## 3. Create Evolution Scene

File: `scenes/main/Evolution.tscn`

```
Control [Script: Evolution.gd]
└── CenterContainer (anchors: full rect)
    └── VBoxContainer
        ├── StatusLabel (Label, text: "EVOLVING THE FIELD...")
        └── ProgressBar (ProgressBar, show_percentage: true)
```

## 4. Create Task 1 (Template for others)

File: `scenes/tasks/Task1_AlignCrystals.tscn`

```
Node2D [Script: Task1_AlignCrystals.gd]
├── Crystal (Sprite2D or ColorRect)
│   └── Set a simple color or texture
├── Target (Sprite2D or ColorRect - different color)
│   └── Place at position like (400, 300)
├── Timer (Timer)
│   └── Set wait_time: 1.0
│   └── one_shot: false
└── CanvasLayer
    └── VBoxContainer (top-left corner)
        ├── LabelInstructions (Label)
        ├── LabelTimer (Label)
        └── (optional) LabelStatus (Label)
```

**For other tasks (Task2-10):**
- Copy this structure
- Change the script
- Add task-specific controls:
  - Task2: Add HSlider
  - Task3: Add two Buttons (LeftButton, RightButton)
  - Task4-10: Add appropriate UI controls per script

## 5. Create One Ending Scene (Template)

File: `scenes/endings/harmonic_garden.tscn`

```
Control [Script: endings/HarmonicGarden.gd]
└── VBoxContainer (centered on screen)
    ├── Title (Label, large font, text: "HARMONIC GARDEN")
    ├── Description (RichTextLabel, autowrap: true)
    └── RestartButton (Button, text: "Try Again")
```

**Repeat for other endings:**
- `scenes/endings/storm_spiral.tscn` → StormSpiral.gd
- `scenes/endings/frozen_collapse.tscn` → FrozenCollapse.gd
- `scenes/endings/runaway_bloom.tscn` → RunawayBloom.gd
- `scenes/endings/stable_equilibrium.tscn` → StableEquilibrium.gd
- `scenes/endings/fractal_cascade.tscn` → FractalCascade.gd

## 6. Set Main Scene

**Project → Project Settings → Application → Run**
- Main Scene: `res://scenes/main/Main.tscn`

## Minimum Viable Product (MVP)

To test the core system quickly, you only need:

1. ✓ FieldManager autoload
2. ✓ Main.tscn with intro
3. ✓ Task1_AlignCrystals.tscn (at minimum)
4. ✓ Evolution.tscn
5. ✓ One ending scene (e.g., stable_equilibrium.tscn)

Then gradually add the other 9 tasks and 5 endings.

## Common Issues

### "Can't find node"
- Check that node names match exactly (case-sensitive)
- Use `$NodeName` or `$Parent/Child/NodeName` paths
- Use `@onready` for nodes that exist at scene start

### "Can't load scene"
- Check file paths in Main.gd task_scenes array
- Make sure .tscn files are saved in correct location
- File names are case-sensitive

### "Signal not connected"
- Signals in code don't need manual connection
- `.connect()` is called in script `_ready()`

### Tasks don't start
- Make sure each task script has `start_task(index: int)` function
- Task must emit `task_completed` signal
- Check that Main.gd can load task scenes

## Testing Checklist

- [ ] FieldManager loads on game start
- [ ] Intro screen shows and button works
- [ ] Task 1 loads and plays
- [ ] Task emits signal when complete
- [ ] Next task loads automatically
- [ ] Evolution screen shows after last task
- [ ] Ending screen appears after evolution
- [ ] Restart button reloads game

## Visual Polish (Later)

Once basic system works:

1. Add background colors/gradients
2. Add particle effects for evolution
3. Add shader effects for field visualization
4. Add sound effects and music
5. Add task-specific visual feedback
6. Add smooth transitions between scenes

---

**Start simple, get it working, then polish!**
