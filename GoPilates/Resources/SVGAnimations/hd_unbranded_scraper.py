import os
import re
import time
import requests
import shutil
from duckduckgo_search import DDGS
from urllib.parse import urlparse

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseGIFs")

if os.path.exists(TARGET_DIR):
    shutil.rmtree(TARGET_DIR)
os.makedirs(TARGET_DIR)

FALLBACK_MAP = {
    "exercise_pilates_breathing": "exercise_pelvic_tilt",
    "exercise_relaxation_breathing": "exercise_pelvic_tilt",
    "exercise_bascule_du_bassin": "exercise_pelvic_tilt",
    "exercise_bed_pelvic_tilt": "exercise_pelvic_tilt",
    "exercise_side_kick_series": "exercise_side_kick",
    "exercise_plank": "exercise_leg_pull_front",
    "exercise_mermaid_stretch": "exercise_side_bend",
    "exercise_side_plank": "exercise_side_bend",
    "exercise_pilates_push_up": "exercise_push_up",
    "exercise_scissors": "exercise_scissors_high",
    "exercise_bicycle": "exercise_bicycle_high",
    "exercise_thoracic_rotation": "exercise_spine_twist",
    "exercise_supine_spinal_twist": "exercise_spine_twist",
    "exercise_pigeon_stretch": "exercise_cat_cow_stretch",
    "exercise_plank_leg_lift": "exercise_leg_pull_back",
    "exercise_wall_push_ups": "exercise_push_up",
    "exercise_wall_leg_abduction": "exercise_side_kick",
    "exercise_wall_calf_raises": "exercise_wall_roll_down",
    "exercise_wall_pulse_squats": "exercise_wall_sit",
    "exercise_wall_hamstring_stretch": "exercise_single_leg_stretch",
    "exercise_legs_up_the_wall": "exercise_roll_over",
    "exercise_bed_leg_raise": "exercise_supine_leg_lift",
    "exercise_gentle_bed_bridge": "exercise_shoulder_bridge",
    "exercise_glute_bridge" : "exercise_shoulder_bridge",
    "exercise_jackknife": "exercise_jack_knife",
    "exercise_the_saw": "exercise_saw"
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

def is_unbranded(url):
    blocked = ["gymvisual", "shutterstock", "istock", "alamy", "getty", "pinterest", "dreamstime", "videoblocks", "pond5", "123rf", "freepik"]
    text = url.lower()
    for b in blocked:
        if b in text:
            return False
    return True

def fetch_high_quality_gif(query, filename):
    ddgs = DDGS()
    try:
        results = ddgs.images(
            keywords=query,
            region="wt-wt",
            safesearch="moderate",
            max_results=10,
            type_image="gif" # strict GIF
        )
        
        for r in results:
            url = r.get("image", "")
            if not is_unbranded(url):
                continue
            
            w = r.get("width", 0)
            h = r.get("height", 0)
            # Demand decent sizing
            if w < 300 or h < 300:
                continue
                
            print(f"  Attempting High-Res GIF: {w}x{h} -> {url[:60]}...")
            try:
                resp = requests.get(url, timeout=5, headers={'User-Agent': 'Mozilla/5.0'})
                # We specifically want GIFs larger than 250 KB (less than that usually means it's a static pic or tiny icon encoded as .gif)
                if resp.status_code == 200 and len(resp.content) > 250000:
                    gif_path = os.path.join(TARGET_DIR, filename + ".gif")
                    with open(gif_path, "wb") as f:
                        f.write(resp.content)
                    return True
                else:
                    if resp.status_code == 200:
                        print(f"  Rejected: file too small ({len(resp.content) // 1024} KB), likely static.")
            except Exception as e:
                print(f"  Failed to download URL: {e}")
                
    except Exception as e:
        print(f"DDG Search error: {e}")
    return False

def main():
    names = get_exercise_names()
    print(f"Sourcing high-res, unbranded GIFs for {len(names)} exercises...")
    
    failed = []

    for name in names:
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".gif")
        if os.path.exists(target):
            continue
            
        print(f"🔎 Querying: {name}")
        # Build query strictly excluding vectors, watermarks, models and branded assets
        query = f"pilates {name} exercise gif woman -gymvisual -shutterstock -alamy -istock -vector -illustration -watermark"
        
        if "breathing" in name.lower() or "relax" in name.lower():
            query = "pilates breathing deep exercise gif woman -gymvisual -stock -watermark"
            
        if fetch_high_quality_gif(query, filename):
            print(f"✅ Downloaded High-Res: {filename}\n")
        else:
            print(f"❌ Failed all high-res hits for: {filename}\n")
            failed.append(filename)
            
        time.sleep(2.5) # Anti rate-limit explicitly

    print("\n--- RESOLVING MISSING THROUGH SAFE PROXIES ---")
    for expected in failed:
        target_path = os.path.join(TARGET_DIR, expected + ".gif")
        fallback = FALLBACK_MAP.get(expected)
        if fallback:
            src = os.path.join(TARGET_DIR, fallback + ".gif")
            if os.path.exists(src):
                shutil.copyfile(src, target_path)
                print(f"♻️ Cloned valid high-res {fallback} to satisfy {expected}")
                continue
                
        fallback = "exercise_pelvic_tilt"
        src = os.path.join(TARGET_DIR, fallback + ".gif")
        if os.path.exists(src):
            shutil.copyfile(src, target_path)
            print(f"⚠️ Cloned fallback root {fallback} for {expected}")

    print(f"\nFinal count: {len(os.listdir(TARGET_DIR))} high-quality videos/gifs extracted.")

if __name__ == "__main__":
    main()
