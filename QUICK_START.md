# ⚡ Quick Start Checklist

Use this to get Chaos Observatory running as fast as possible.

## ✅ Scripts Status
All 24 scripts are complete and ready:
- [x] Core system (3 files)
- [x] 10 task scripts
- [x] 6 ending scripts
- [x] Documentation (4 files)
- [x] Test script

## 🎯 Setup Steps (Do These Now)

### Step 1: Configure Autoload (2 minutes)
1. Open Godot
2. Go to **Project → Project Settings → Autoload**
3. Click the folder icon
4. Navigate to `scripts/FieldManager.gd`
5. Node Name: `FieldManager` (should auto-fill)
6. Click **Add**
7. Close settings

**Verify:** You should see `FieldManager` in the autoload list

---

### Step 2: Create Minimal Main Scene (5 minutes)

Create: `scenes/main/Main.tscn`

**Minimum viable structure:**
```
Control [Attach script: scripts/Main.gd]
├── IntroPanel (Panel)
│   └── VBoxContainer
│       ├── Label (text: "CHAOS OBSERVATORY")
│       ├── Button (name: "StartButton", text: "START")
└── TaskContainer (Control - leave empty)
```

**Critical:**
- Root node must be `Control`
- Button must be named exactly `StartButton`
- TaskContainer must be named exactly `TaskContainer`

---

### Step 3: Create ONE Task Scene (10 minutes)

Create: `scenes/tasks/Task1_AlignCrystals.tscn`

**Minimum viable structure:**
```
Node2D [Attach script: scripts/Task1_AlignCrystals.gd]
├── Crystal (ColorRect, size: 50x50, color: cyan)
│   └── Position: (200, 200)
├── Target (ColorRect, size: 60x60, color: yellow)
│   └── Position: (400, 300)
├── Timer (Timer, wait_time: 1.0)
└── CanvasLayer
    └── VBoxContainer (position: top-left, padding: 10)
        ├── LabelInstructions (Label)
        ├── LabelTimer (Label)
        └── LabelStatus (Label) [optional]
```

**Tips:**
- ColorRects are fine for prototype
- Don't worry about pretty visuals yet
- Just get it functional

---

### Step 4: Create Evolution Scene (3 minutes)

Create: `scenes/main/Evolution.tscn`

```
Control [Attach script: scripts/Evolution.gd]
└── CenterContainer (anchors: full rect)
    └── VBoxContainer
        ├── StatusLabel (Label, text: "EVOLVING...")
        └── ProgressBar (ProgressBar)
```

---

### Step 5: Create ONE Ending Scene (5 minutes)

Create: `scenes/endings/stable_equilibrium.tscn`

```
Control [Attach script: scripts/endings/StableEquilibrium.gd]
└── VBoxContainer (centered on screen)
    ├── Title (Label, large font)
    ├── Description (RichTextLabel)
    └── RestartButton (Button, text: "Try Again")
```

**Position:** Center the VBoxContainer at (512, 300) or use anchors

---

### Step 6: Set Main Scene (30 seconds)

1. **Project → Project Settings → Application → Run**
2. Main Scene: `res://scenes/main/Main.tscn`
3. Click **Select Current** if Main.tscn is open
4. Close settings

---

### Step 7: First Test Run! (NOW!)

1. Press **F5** or click Play
2. You should see:
   - Intro screen with START button ✓
   - Click START
   - Task 1 loads ✓
   - You can drag the crystal
   - Timer counts down
   - Task completes
   - Error: "Can't load Task2" (expected - we only made Task 1)

**If you got this far: SUCCESS! The core system works!**

---

## 🚀 Next Steps (After First Test)

### Option A: Quick Complete System (60 minutes)
Copy Task1 scene 9 times, rename, attach correct scripts. Repeat for all endings.

### Option B: Incremental Build (Recommended)
1. Make Task 2 (test it)
2. Make Task 3 (test it)
3. Continue until all 10 done
4. Then make all 6 endings
5. Final complete test

---

## 🐛 Common First-Run Issues

### "FieldManager not found"
→ Did you set up Autoload? (Step 1)

### "Can't instantiate script"
→ Check script paths match scene names exactly

### "Node not found: $IntroPanel"
→ Check node names are exactly as specified

### "Signal 'pressed' not found"
→ Make sure button is actually a Button node

### Task doesn't start
→ Verify Timer node exists and is configured

### Black screen
→ Check that Main.tscn is set as main scene (Step 6)

---

## ⚡ Ultra-Fast MVP (If Time-Constrained)

**Absolute minimum to test chaos system:**

1. Autoload FieldManager ✓
2. Create Main.tscn (with intro) ✓
3. Create Task1 scene only ✓
4. Modify Main.gd temporarily:
   ```gdscript
   var task_scenes := [
       "res://scenes/tasks/Task1_AlignCrystals.tscn"
       # Comment out tasks 2-10
   ]
   ```
5. Create stable_equilibrium.tscn only ✓
6. Modify Main.gd show_ending():
   ```gdscript
   # Hardcode to stable_equilibrium for testing
   var ending_path = "res://scenes/endings/stable_equilibrium.tscn"
   ```

**This tests the entire flow with minimal work!**

Then expand from there.

---

## 📋 Progress Tracker

- [ ] Step 1: Autoload configured
- [ ] Step 2: Main scene created
- [ ] Step 3: Task 1 scene created
- [ ] Step 4: Evolution scene created
- [ ] Step 5: One ending scene created
- [ ] Step 6: Main scene set as default
- [ ] Step 7: First successful test run
- [ ] Step 8: All 10 tasks created
- [ ] Step 9: All 6 endings created
- [ ] Step 10: Full playthrough test
- [ ] Step 11: Visual polish added
- [ ] Step 12: Web export configured

---

## 🎯 Success Criteria

You'll know it works when:

✅ Game starts with intro screen
✅ START button loads first task
✅ Task timer counts down
✅ Task interaction works (drag crystal)
✅ Task auto-completes when timer ends
✅ Next task loads automatically
✅ After Task 10, evolution screen shows
✅ Progress bar fills for 5 seconds
✅ Ending screen appears
✅ Restart button reloads game
✅ Different task performance → different endings

---

## 💡 Pro Tips

1. **Test incrementally** - Don't build everything before testing
2. **Use ColorRects** for quick prototypes
3. **Print statements** are your friend: `print("Task completed:", task_index)`
4. **Check Output panel** for errors
5. **Save often** - Godot can crash
6. **Use Ctrl+D to duplicate** nodes/scenes quickly

---

## 🆘 Need Help?

Check these files:
- `SCENE_SETUP_GUIDE.md` - Detailed scene instructions
- `README_IMPLEMENTATION.md` - Complete system overview
- `CHAOS_THEORY_TECHNICAL.md` - How the math works
- `PROJECT_SUMMARY.md` - Big picture view

Or attach `TestChaosSystem.gd` to a Node and run it to test core logic without UI!

---

**You're 30-60 minutes away from a working chaos theory game! 🚀**

Start with Step 1 right now!
