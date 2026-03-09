import os
import re
import subprocess

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseVideos")

# Fallback mapping if standard search returns garbage
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

if not os.path.exists(TARGET_DIR):
    os.makedirs(TARGET_DIR)

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

def fetch_youtube_video(query, final_mp4_path):
    print(f"  Fetching byte-sections: {query}")
    tmp_path = os.path.join(TARGET_DIR, "tmp_download.mp4")
    if os.path.exists(tmp_path): os.remove(tmp_path)
        
    import imageio_ffmpeg
    ffmpeg_exe = imageio_ffmpeg.get_ffmpeg_exe()

    cmd_yt = [
        "/private/tmp/gif_env/bin/yt-dlp",
        "--ffmpeg-location", ffmpeg_exe,
        "--download-sections", "*00:00:01-00:00:08",
        "-f", "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/mp4",
        "-o", tmp_path,
        f"ytsearch1:{query}"
    ]
    
    try:
        subprocess.run(cmd_yt, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if not os.path.exists(tmp_path):
            return False

        # Super-fast secondary pass to strip audio and compress the 7s clip
        cmd_ffmpeg = [
            ffmpeg_exe, "-y",
            "-i", tmp_path,
            "-vf", "scale=-2:800",
            "-c:v", "libx264",
            "-crf", "30",
            "-preset", "ultrafast",
            "-an",
            final_mp4_path
        ]
        
        subprocess.run(cmd_ffmpeg, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        os.remove(tmp_path)
        return True
    except Exception as e:
        print(f"  Failed: {e}")
        return False

def main():
    names = get_exercise_names()
    print(f"Downloading premium offline MP4 videos (looping silently) for {len(names)} exercises...")
    failed = []

    for name in names:
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".mp4")
        if os.path.exists(target):
            continue
            
        print(f"🔎 YT Querying: {name}")
        query = f"pilates {name} exercise short"
        
        if "breathing" in name.lower() or "relax" in name.lower():
            query = "pilates perfect deep breathing technique short"
            
        if fetch_youtube_video(query, target):
            size_kb = os.path.getsize(target) / 1024
            print(f"✅ Extracted 6s looping MP4 [{int(size_kb)}KB]: {filename}\n")
        else:
            print(f"❌ Failed all downloads for: {filename}\n")
            failed.append(filename)

    print("\n--- RESOLVING MISSING (VIA LOCAL CLONES) ---")
    import shutil
    for expected in failed:
        target_path = os.path.join(TARGET_DIR, expected + ".mp4")
        fallback = FALLBACK_MAP.get(expected)
        if fallback:
            src = os.path.join(TARGET_DIR, fallback + ".mp4")
            if os.path.exists(src):
                shutil.copyfile(src, target_path)
                print(f"♻️ Cloned core video {fallback} for {expected}")
                continue
                
        fallback = "exercise_pelvic_tilt"
        src = os.path.join(TARGET_DIR, fallback + ".mp4")
        if os.path.exists(src):
            shutil.copyfile(src, target_path)
            print(f"⚠️ Cloned baseline {fallback} for {expected}")

    print(f"\nFinal count: {len([f for f in os.listdir(TARGET_DIR) if f.endswith('.mp4')])} premium workout videos.")

if __name__ == "__main__":
    main()
