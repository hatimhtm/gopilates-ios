import os
import re
import time
import requests
import urllib.parse
from playwright.sync_api import sync_playwright

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseGIFs")

if not os.path.exists(TARGET_DIR):
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
    blocked = ["gymvisual", "shutterstock", "istock", "alamy", "getty", "pinterest", "dreamstime", "videoblocks", "pond5", "123rf", "freepik", "vector"]
    text = url.lower()
    for b in blocked:
        if b in text:
            return False
    return True

def fetch_high_quality_gif(page, query, filename):
    encoded_query = urllib.parse.quote(query)
    url = f"https://duckduckgo.com/?q={encoded_query}&iax=images&ia=images"
    
    try:
        page.goto(url, wait_until="domcontentloaded", timeout=15000)
        time.sleep(2) # let JS load images
        
        # Look for the tiles
        tiles = page.query_selector_all(".tile--img")
        for tile in tiles[:6]:
            try:
                # get the raw href from the tile's wrapping a tag if possible to see domain
                a_tag = tile.query_selector("a")
                if a_tag:
                    href = a_tag.get_attribute("href") or ""
                    if not is_unbranded(href):
                        continue
                        
                tile.click(timeout=3000)
                time.sleep(1.5) # Wait for the detail panel to open
                
                # Get the detailed image high res link
                detail_img = page.query_selector(".detail__media__img-highres")
                if not detail_img:
                    continue
                    
                img_url = detail_img.get_attribute("src")
                if not img_url or not detail_img.is_visible():
                    continue
                
                # Verify URL is unbranded
                if not is_unbranded(img_url):
                    continue

                print(f"  Attempting High-Res GIF: {img_url[:80]}...")
                resp = requests.get(img_url, timeout=5, headers={'User-Agent': 'Mozilla/5.0'})
                
                # Only accept GIF/videos > 250KB to bypass static thumbnails
                if resp.status_code == 200 and len(resp.content) > 150000:
                    gif_path = os.path.join(TARGET_DIR, filename + ".gif")
                    with open(gif_path, "wb") as f:
                        f.write(resp.content)
                    return True
                else:
                    if resp.status_code == 200:
                        print(f"  Rejected: file too small ({len(resp.content) // 1024} KB), likely static.")
            except Exception as inner_e:
                print(f"  Error investigating tile: {inner_e}")
                pass

    except Exception as e:
        print(f"  Playwright timeout/error: {e}")
        
    return False

def main():
    names = get_exercise_names()
    print(f"Sourcing high-res, unbranded GIFs using Playwright for {len(names)} exercises...")
    failed = []

    with sync_playwright() as p:
        # User agents and stealth behavior
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36")
        page = context.new_page()

        for name in names:
            filename = format_filename(name)
            target = os.path.join(TARGET_DIR, filename + ".gif")
            
            # Delete if currently exists but < 150KB (aka the bad thumbnails)
            if os.path.exists(target):
                if os.path.getsize(target) < 150000:
                    os.remove(target)
                else:
                    print(f"✅ Skipping {name}, already valid HD size.")
                    continue
                
            print(f"🔎 Playwright Search: {name}")
            query = f"pilates {name} exercise animated gif woman -gymvisual -shutterstock -watermark -vector -illustration"
            
            if "breathing" in name.lower() or "relax" in name.lower():
                query = "pilates breathing deep exercise animated gif woman -gymvisual"
                
            if fetch_high_quality_gif(page, query, filename):
                print(f"✅ Downloaded High-Res HD: {filename}\n")
            else:
                print(f"❌ Failed to extract HD file for: {filename}\n")
                failed.append(filename)

        browser.close()

    print("\n--- RESOLVING MISSING (VIA LOCAL CLONES) ---")
    import shutil
    for expected in failed:
        target_path = os.path.join(TARGET_DIR, expected + ".gif")
        fallback = FALLBACK_MAP.get(expected)
        if fallback:
            src = os.path.join(TARGET_DIR, fallback + ".gif")
            if os.path.exists(src) and os.path.getsize(src) > 150000:
                shutil.copyfile(src, target_path)
                print(f"♻️ Cloned HD {fallback} for {expected}")
                continue
                
        fallback = "exercise_pelvic_tilt"
        src = os.path.join(TARGET_DIR, fallback + ".gif")
        if os.path.exists(src) and os.path.getsize(src) > 150000:
            shutil.copyfile(src, target_path)
            print(f"⚠️ Cloned fallback root {fallback} for {expected}")

    print(f"\n✅ All done. Files matching criteria: {len(os.listdir(TARGET_DIR))}")

if __name__ == "__main__":
    main()
