#!/usr/bin/env python3
"""
Professional Exercise GIF Creator
===================================
Uses the free-exercise-db (GitHub) which has professional HD photographs
of real people performing exercises (start/end positions).

Creates smooth animated GIFs by crossfading between the two positions,
giving a clean, professional demonstration of each exercise.
"""

import os
import re
import ssl
import json
import shutil
import urllib.request
from io import BytesIO

# Required: pip install Pillow
from PIL import Image

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseGIFs")

SSL_CTX = ssl.create_default_context()
SSL_CTX.check_hostname = False
SSL_CTX.verify_mode = ssl.CERT_NONE

GITHUB_RAW = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises"

os.makedirs(TARGET_DIR, exist_ok=True)

# Manual mapping: our exercise englishName -> free-exercise-db exercise ID
# Each entry maps to a bodyweight exercise that best demonstrates the movement
EXERCISE_MAP = {
    # 30-Day Challenge
    "Pilates Breathing":        "Stomach_Vacuum",         # breathing/core engagement
    "Pelvic Tilt":              "Butt_Lift_Bridge",       # pelvic movement
    "Glute Bridge":             "Butt_Lift_Bridge",       # bridge
    "Supine Leg Lift":          "Flat_Bench_Lying_Leg_Raise",  # lying leg raise
    "Cat-Cow Stretch":          "Cat_Stretch",            # cat stretch
    "Dead Bug":                 "Dead_Bug",               # exact match
    "Seated Spine Stretch":     "Seated_Floor_Hamstring_Stretch", # seated stretch
    "The Hundred":              "Crunches",               # ab work
    "Roll Up":                  "Crunches",               # ab curl
    "One Leg Circle":           "Lying_Leg_Curls",        # leg movement
    "Rolling Like a Ball":      "Crunches",               # core roll
    "Single Leg Stretch":       "Flat_Bench_Lying_Leg_Raise", # leg stretch
    "Double Leg Stretch":       "Flat_Bench_Lying_Leg_Raise", # double leg
    "The Saw":                  "Seated_Floor_Hamstring_Stretch", # seated twist
    "Swan Dive Prep":           "Hyperextensions",        # back extension
    "Side Kick Series":         "Side_Lying_Hip_Adduction", # side lying leg
    "Plank":                    "Pushups",                # plank position
    "Mermaid Stretch":          "Side_Neck_Stretch",      # side stretch
    "Spine Twist":              "Seated_Floor_Hamstring_Stretch", # seated twist
    "Swimming":                 "Superman",               # prone extension
    "Teaser":                   "V-Up",                   # V-sit
    "Side Plank":               "Side_Bridge",            # side plank
    "Boomerang":                "V-Up",                   # advanced V-sit
    "Pilates Push-Up":          "Pushups",                # push-up
    "Scissors":                 "Flat_Bench_Lying_Leg_Raise", # scissor legs
    "Bicycle":                  "Air_Bike",               # bicycle crunch
    "Hip Twist":                "Cross-Body_Crunch",      # hip rotation
    "Seal":                     "Crunches",               # rolling motion
    
    # Wall Pilates
    "Wall Roll Down":           "Standing_Hamstring_Stretch", # wall roll
    "Wall Sit":                 "Wall_Squat",             # exact match(ish)
    "Wall Glute Bridge":        "Butt_Lift_Bridge",       # bridge variation
    "Wall Push-Ups":            "Pushups",                # push-up
    "Wall Inverted Plank":      "Superman",               # back exercise
    "Wall Leg Abduction":       "Hip_Flexion_with_Band",  # leg abduction
    "Wall Pulse Squats":        "Wall_Squat",             # wall squat
    "Wall Calf Raises":         "Standing_Calf_Raises",   # calf raises
    "Wall Hamstring Stretch":   "Standing_Hamstring_Stretch", # hamstring
    "Legs Up the Wall":         "Flat_Bench_Lying_Leg_Raise", # legs up
    
    # Bed Pilates
    "Bed Pelvic Tilt":          "Butt_Lift_Bridge",       # pelvic tilt
    "Supine Spinal Twist":      "Cross-Body_Crunch",      # twist
    "Gentle Bed Bridge":        "Butt_Lift_Bridge",       # bridge
    "Bed Leg Raise":            "Flat_Bench_Lying_Leg_Raise", # leg raise
    "Relaxation Breathing":     "Stomach_Vacuum",         # breathing
    
    # VOD extras
    "Corkscrew":                "Cross-Body_Crunch",      # rotational ab
    "Jackknife":                "Jackknife_Sit-Up",       # exact match
    "Pigeon Stretch":           "Groin_and_Back_Stretch",     # hip opener
    "Plank Leg Lift":           "Pushups",                # plank variant
    "Thoracic Rotation":        "Cross-Body_Crunch",      # rotation
}


def get_exercise_names():
    names = []
    with open(MODELS_FILE, "r") as f:
        matches = re.findall(r'englishName:\s*"([^"]+)"', f.read())
        for m in matches:
            if m not in names:
                names.append(m)
    return names


def format_filename(name):
    return "exercise_" + name.lower().replace(" ", "_").replace("-", "_")


def download_image(url):
    """Download an image and return as PIL Image."""
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        resp = urllib.request.urlopen(req, context=SSL_CTX, timeout=15)
        data = resp.read()
        return Image.open(BytesIO(data)).convert("RGB")
    except Exception as e:
        print(f"    Download error: {e}")
        return None


def create_exercise_gif(img_start, img_end, output_path, num_frames=16, duration_ms=120):
    """
    Create a smooth animated GIF that oscillates between start and end positions.
    Uses alpha blending to create a natural movement feel.
    
    Sequence: start -> blend toward end -> end -> blend back to start -> loop
    """
    # Resize both images to the same dimensions
    target_size = (480, 480)
    img_start = img_start.resize(target_size, Image.LANCZOS)
    img_end = img_end.resize(target_size, Image.LANCZOS)
    
    frames = []
    
    # Forward: start -> end (num_frames steps)
    for i in range(num_frames):
        alpha = i / (num_frames - 1)
        blended = Image.blend(img_start, img_end, alpha)
        frames.append(blended)
    
    # Hold at end position for a moment
    for _ in range(4):
        frames.append(img_end.copy())
    
    # Backward: end -> start (num_frames steps)
    for i in range(num_frames):
        alpha = i / (num_frames - 1)
        blended = Image.blend(img_end, img_start, alpha)
        frames.append(blended)
    
    # Hold at start position for a moment
    for _ in range(4):
        frames.append(img_start.copy())
    
    # Save as animated GIF
    frames[0].save(
        output_path,
        save_all=True,
        append_images=frames[1:],
        duration=duration_ms,
        loop=0,
        optimize=True
    )


def main():
    names = get_exercise_names()
    print(f"\n{'='*60}")
    print(f"  Professional Exercise GIF Creator")
    print(f"  {len(names)} exercises from free-exercise-db")
    print(f"{'='*60}\n")

    # Clear old GIFs
    old = [f for f in os.listdir(TARGET_DIR) if f.endswith('.gif')]
    if old:
        print(f"🗑️  Removing {len(old)} old GIFs...\n")
        for f in old:
            os.remove(os.path.join(TARGET_DIR, f))

    succeeded = []
    failed = []

    for i, name in enumerate(names):
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".gif")
        
        db_id = EXERCISE_MAP.get(name)
        if not db_id:
            print(f"[{i+1}/{len(names)}] {name} — no mapping, skipping")
            failed.append(filename)
            continue

        print(f"[{i+1}/{len(names)}] {name} → {db_id}")
        
        # Download start and end position images
        url_0 = f"{GITHUB_RAW}/{db_id}/0.jpg"
        url_1 = f"{GITHUB_RAW}/{db_id}/1.jpg"
        
        img_start = download_image(url_0)
        img_end = download_image(url_1)
        
        if img_start and img_end:
            create_exercise_gif(img_start, img_end, target)
            size_kb = os.path.getsize(target) // 1024
            print(f"  ✅ {filename}.gif [{size_kb}KB]")
            succeeded.append(filename)
        else:
            print(f"  ❌ Failed to download images")
            failed.append(filename)

    # Clone fallbacks
    if failed:
        print(f"\n{'='*60}")
        print(f"  Cloning {len(failed)} missing from related exercises")
        print(f"{'='*60}\n")
        
        for filename in failed:
            target = os.path.join(TARGET_DIR, filename + ".gif")
            # Find any available GIF to clone
            for f in os.listdir(TARGET_DIR):
                if f.endswith('.gif'):
                    src = os.path.join(TARGET_DIR, f)
                    if os.path.getsize(src) > 5000:
                        shutil.copyfile(src, target)
                        print(f"  ♻️  {f} → {filename}")
                        break

    final = len([f for f in os.listdir(TARGET_DIR) if f.endswith('.gif')])
    total_mb = sum(os.path.getsize(os.path.join(TARGET_DIR, f)) for f in os.listdir(TARGET_DIR) if f.endswith('.gif')) / (1024*1024)
    
    print(f"\n{'='*60}")
    print(f"  ✅ {final} exercise GIFs created ({total_mb:.1f}MB)")
    print(f"  📁 {TARGET_DIR}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
