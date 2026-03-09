
#!/usr/bin/env python3
"""
Exercise GIF Downloader — Tenor + GIPHY
=========================================
Downloads real exercise demonstration GIFs from:
  1. Tenor (Google's GIF engine) — primary source
  2. GIPHY — fallback

These APIs return short, looping, animated GIFs of people actually
performing exercises. No intros, no talking, just the movement.
"""

import os
import re
import json
import ssl
import shutil
import urllib.request
import urllib.parse

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseGIFs")

# SSL context (macOS Python has cert issues)
SSL_CTX = ssl.create_default_context()
SSL_CTX.check_hostname = False
SSL_CTX.verify_mode = ssl.CERT_NONE

# Tenor public API key
TENOR_KEY = "AIzaSyAyimkuYQYF_FXVALexPuGQctUWRURdCYQ"

# GIPHY public beta key
GIPHY_KEY = "dc6zaTOxFJmzC"

os.makedirs(TARGET_DIR, exist_ok=True)

# Search queries tuned per exercise to get THE ACTUAL MOVEMENT
QUERIES = {
    "Pilates Breathing":        ["pilates breathing exercise", "diaphragmatic breathing exercise"],
    "Pelvic Tilt":              ["pelvic tilt exercise", "pelvic tilt pilates mat"],
    "Glute Bridge":             ["glute bridge exercise", "bridge exercise fitness"],
    "Supine Leg Lift":          ["leg raise exercise", "lying leg lift exercise"],
    "Cat-Cow Stretch":          ["cat cow stretch", "cat cow exercise yoga"],
    "Dead Bug":                 ["dead bug exercise", "dead bug core workout"],
    "Seated Spine Stretch":     ["spine stretch exercise seated", "seated forward fold stretch"],
    "The Hundred":              ["pilates hundred exercise", "pilates hundred"],
    "Roll Up":                  ["pilates roll up exercise", "roll up ab exercise"],
    "One Leg Circle":           ["leg circle exercise pilates", "single leg circle"],
    "Rolling Like a Ball":      ["rolling like a ball pilates", "pilates rolling"],
    "Single Leg Stretch":       ["single leg stretch pilates", "single leg pull exercise"],
    "Double Leg Stretch":       ["double leg stretch pilates", "double leg stretch exercise"],
    "The Saw":                  ["pilates saw exercise", "saw twist exercise"],
    "Swan Dive Prep":           ["swan dive pilates", "cobra exercise back extension"],
    "Side Kick Series":         ["side lying leg lift exercise", "side kick exercise"],
    "Plank":                    ["plank exercise", "plank hold fitness"],
    "Mermaid Stretch":          ["mermaid stretch pilates", "side stretch exercise"],
    "Spine Twist":              ["spine twist pilates seated", "seated twist exercise"],
    "Swimming":                 ["pilates swimming exercise", "superman exercise prone"],
    "Teaser":                   ["pilates teaser exercise", "v sit up exercise"],
    "Side Plank":               ["side plank exercise", "side plank hold"],
    "Boomerang":                ["pilates boomerang exercise", "pilates advanced exercise"],
    "Pilates Push-Up":          ["pilates push up", "push up exercise"],
    "Scissors":                 ["scissors exercise ab", "pilates scissors leg"],
    "Bicycle":                  ["bicycle crunch exercise", "bicycle exercise ab"],
    "Hip Twist":                ["hip twist exercise", "hip circles exercise"],
    "Seal":                     ["pilates seal exercise", "pilates rolling exercise"],
    "Wall Roll Down":           ["wall roll down exercise", "standing roll down stretch"],
    "Wall Sit":                 ["wall sit exercise", "wall squat hold"],
    "Wall Glute Bridge":        ["wall bridge exercise", "wall glute bridge"],
    "Wall Push-Ups":            ["wall push up exercise", "wall push ups"],
    "Wall Inverted Plank":      ["inverted plank exercise", "reverse plank exercise"],
    "Wall Leg Abduction":       ["standing leg abduction", "hip abduction exercise"],
    "Wall Pulse Squats":        ["pulse squat exercise", "wall squat pulse"],
    "Wall Calf Raises":         ["calf raises exercise", "standing calf raise"],
    "Wall Hamstring Stretch":   ["hamstring stretch exercise", "standing hamstring stretch"],
    "Legs Up the Wall":         ["legs up the wall pose", "legs up wall stretch"],
    "Bed Pelvic Tilt":          ["pelvic tilt exercise lying", "pelvic tilt beginner"],
    "Supine Spinal Twist":      ["supine twist stretch", "lying spinal twist"],
    "Gentle Bed Bridge":        ["bridge exercise beginner", "glute bridge gentle"],
    "Bed Leg Raise":            ["lying leg raise exercise", "supine leg raise"],
    "Relaxation Breathing":     ["deep breathing exercise relaxation", "breathing exercise calm"],
    "Corkscrew":                ["pilates corkscrew exercise", "corkscrew ab exercise"],
    "Jackknife":                ["jackknife exercise", "pilates jackknife"],
    "Pigeon Stretch":           ["pigeon stretch exercise", "pigeon pose stretch"],
    "Plank Leg Lift":           ["plank leg lift exercise", "plank leg raise"],
    "Thoracic Rotation":        ["thoracic rotation exercise", "upper back rotation stretch"],
}

FALLBACK_MAP = {
    "exercise_pilates_breathing":       "exercise_pelvic_tilt",
    "exercise_relaxation_breathing":    "exercise_pilates_breathing",
    "exercise_bed_pelvic_tilt":         "exercise_pelvic_tilt",
    "exercise_side_plank":              "exercise_plank",
    "exercise_pilates_push_up":         "exercise_wall_push_ups",
    "exercise_gentle_bed_bridge":       "exercise_glute_bridge",
    "exercise_bed_leg_raise":           "exercise_supine_leg_lift",
    "exercise_wall_pulse_squats":       "exercise_wall_sit",
    "exercise_wall_calf_raises":        "exercise_wall_sit",
    "exercise_wall_hamstring_stretch":  "exercise_legs_up_the_wall",
    "exercise_supine_spinal_twist":     "exercise_spine_twist",
    "exercise_thoracic_rotation":       "exercise_spine_twist",
    "exercise_plank_leg_lift":          "exercise_plank",
    "exercise_the_saw":                 "exercise_spine_twist",
    "exercise_jackknife":               "exercise_teaser",
    "exercise_pigeon_stretch":          "exercise_mermaid_stretch",
    "exercise_boomerang":               "exercise_teaser",
    "exercise_corkscrew":               "exercise_hip_twist",
    "exercise_swan_dive_prep":          "exercise_swimming",
    "exercise_seal":                    "exercise_rolling_like_a_ball",
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


def download_file(url, path):
    """Download a file with SSL workaround."""
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, context=SSL_CTX, timeout=15) as resp:
        with open(path, "wb") as f:
            f.write(resp.read())
    return os.path.exists(path) and os.path.getsize(path) > 20000


def is_exercise_gif(url):
    """Filter out obvious non-exercise content."""
    bad = ["reaction", "funny", "meme", "cat", "dog", "anime", "cartoon", "movie", "celebrity"]
    text = url.lower()
    return not any(b in text for b in bad)


def search_tenor(query):
    """Search Tenor for exercise GIFs. Returns list of GIF URLs."""
    encoded = urllib.parse.quote(query)
    url = f"https://tenor.googleapis.com/v2/search?q={encoded}&key={TENOR_KEY}&limit=8&media_filter=gif&contentfilter=medium"
    
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, context=SSL_CTX, timeout=10)
        data = json.loads(resp.read())
        
        urls = []
        for r in data.get("results", []):
            mf = r.get("media_formats", {})
            # Prefer mediumgif for good quality + reasonable size
            for fmt in ["mediumgif", "gif"]:
                if fmt in mf:
                    gif_url = mf[fmt].get("url")
                    size = mf[fmt].get("size", 0)
                    if gif_url and is_exercise_gif(gif_url) and size > 50000:
                        urls.append(gif_url)
                    break
        return urls
    except Exception as e:
        print(f"    Tenor error: {e}")
        return []


def search_giphy(query):
    """Search GIPHY for exercise GIFs. Returns list of GIF URLs."""
    encoded = urllib.parse.quote(query)
    url = f"https://api.giphy.com/v1/gifs/search?api_key={GIPHY_KEY}&q={encoded}&limit=5&rating=g"
    
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, context=SSL_CTX, timeout=10)
        data = json.loads(resp.read())
        
        urls = []
        for r in data.get("data", []):
            images = r.get("images", {})
            # Get the "original" or "downsized" version
            for fmt in ["original", "downsized_medium", "downsized"]:
                if fmt in images:
                    gif_url = images[fmt].get("url")
                    if gif_url and is_exercise_gif(gif_url):
                        urls.append(gif_url)
                    break
        return urls
    except Exception as e:
        print(f"    GIPHY error: {e}")
        return []


def download_gif_for_exercise(english_name, filename):
    """Try to download a GIF for an exercise from multiple sources."""
    target = os.path.join(TARGET_DIR, filename + ".gif")
    queries = QUERIES.get(english_name, [f"{english_name} exercise"])
    
    # Try each query across both APIs
    for query in queries:
        # Try Tenor first
        print(f"    🔍 Tenor: '{query}'")
        urls = search_tenor(query)
        for gif_url in urls:
            try:
                if download_file(gif_url, target):
                    return True
            except Exception:
                continue
        
        # Try GIPHY
        print(f"    🔍 GIPHY: '{query}'")  
        urls = search_giphy(query)
        for gif_url in urls:
            try:
                if download_file(gif_url, target):
                    return True
            except Exception:
                continue
    
    return False


def main():
    names = get_exercise_names()
    print(f"\n{'='*60}")
    print(f"  Exercise GIF Downloader (Tenor + GIPHY)")
    print(f"  {len(names)} exercises to source")
    print(f"{'='*60}\n")

    # Delete old .gif files (the math-generated ones)
    old_gifs = [f for f in os.listdir(TARGET_DIR) if f.endswith('.gif')]
    if old_gifs:
        print(f"🗑️  Removing {len(old_gifs)} old generated GIFs...\n")
        for f in old_gifs:
            os.remove(os.path.join(TARGET_DIR, f))

    succeeded = []
    failed = []

    for i, name in enumerate(names):
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".gif")
        
        if os.path.exists(target) and os.path.getsize(target) > 20000:
            print(f"[{i+1}/{len(names)}] {name} — already exists, skipping")
            succeeded.append(filename)
            continue

        print(f"[{i+1}/{len(names)}] {name}")
        
        if download_gif_for_exercise(name, filename):
            size_kb = os.path.getsize(target) // 1024
            print(f"  ✅ {filename}.gif [{size_kb}KB]\n")
            succeeded.append(filename)
        else:
            print(f"  ❌ Failed\n")
            failed.append(filename)

    # Fallback cloning for missing exercises
    if failed:
        print(f"\n{'='*60}")
        print(f"  Cloning {len(failed)} missing from related exercises")
        print(f"{'='*60}\n")
        
        still_missing = []
        for filename in failed:
            target = os.path.join(TARGET_DIR, filename + ".gif")
            fb = FALLBACK_MAP.get(filename)
            if fb:
                src = os.path.join(TARGET_DIR, fb + ".gif")
                if os.path.exists(src) and os.path.getsize(src) > 20000:
                    shutil.copyfile(src, target)
                    print(f"  ♻️  {fb} → {filename}")
                    continue
            
            # Try any available exercise as last resort
            for f in os.listdir(TARGET_DIR):
                if f.endswith('.gif'):
                    src = os.path.join(TARGET_DIR, f)
                    if os.path.getsize(src) > 20000:
                        shutil.copyfile(src, target)
                        print(f"  ⚠️  {f} → {filename}")
                        break
            else:
                still_missing.append(filename)

        if still_missing:
            print(f"\n  Still missing: {still_missing}")

    final = len([f for f in os.listdir(TARGET_DIR) if f.endswith('.gif') and os.path.getsize(os.path.join(TARGET_DIR, f)) > 20000])
    total_mb = sum(os.path.getsize(os.path.join(TARGET_DIR, f)) for f in os.listdir(TARGET_DIR) if f.endswith('.gif')) / (1024*1024)
    
    print(f"\n{'='*60}")
    print(f"  ✅ Done! {final} exercise GIFs ({total_mb:.1f}MB total)")
    print(f"  📁 {TARGET_DIR}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
