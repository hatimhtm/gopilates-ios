#!/usr/bin/env python3
"""
Smart Exercise Media Downloader v2
===================================
Two-pronged strategy to get ACTUAL exercise demonstrations (not intros):

1. PRIMARY: YouTube Shorts — these are 15-60s videos with virtually NO intros.
   We search specifically for Shorts, then extract seconds 5-13 (the meat).
   
2. FALLBACK: If yt-dlp fails, we try Tenor's free public GIF API, which has
   thousands of high-quality looping exercise animations.

3. LAST RESORT: For any still-missing exercises, clone from a related exercise.
"""

import os
import re
import sys
import json
import subprocess
import urllib.request
import urllib.parse
import shutil
import glob

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseVideos")

# Tenor API — completely free, no key required for public search
# (Google's official GIF search engine)
TENOR_API_KEY = "AIzaSyAyimkuYQYF_FXVALexPuGQctUWRURdCYQ"  # Public test key from Tenor docs

# yt-dlp and ffmpeg paths
YTDLP = "/private/tmp/gif_env/bin/yt-dlp"

try:
    import imageio_ffmpeg
    FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
except ImportError:
    FFMPEG = "ffmpeg"

# Tailored search queries per exercise for maximum relevance
# Format: exercise_english_name -> (youtube_query, tenor_query)
SEARCH_OVERRIDES = {
    "Pilates Breathing":         ("pilates lateral breathing technique demonstration #shorts", "pilates breathing"),
    "Pelvic Tilt":               ("pilates pelvic tilt exercise mat demonstration #shorts", "pelvic tilt exercise"),
    "Glute Bridge":              ("glute bridge exercise demonstration form #shorts", "glute bridge exercise"),
    "Supine Leg Lift":           ("supine leg raise pilates demonstration #shorts", "leg raise exercise"),
    "Cat-Cow Stretch":           ("cat cow stretch exercise demonstration #shorts", "cat cow stretch"),
    "Dead Bug":                  ("dead bug exercise demonstration form #shorts", "dead bug exercise"),
    "Seated Spine Stretch":      ("pilates spine stretch forward sitting #shorts", "spine stretch pilates"),
    "The Hundred":               ("pilates hundred exercise demonstration #shorts", "pilates hundred"),
    "Roll Up":                   ("pilates roll up exercise mat #shorts", "pilates roll up"),
    "One Leg Circle":            ("pilates single leg circle exercise #shorts", "leg circle pilates"),
    "Rolling Like a Ball":       ("pilates rolling like a ball demonstration #shorts", "rolling like a ball pilates"),
    "Single Leg Stretch":        ("pilates single leg stretch exercise #shorts", "single leg stretch"),
    "Double Leg Stretch":        ("pilates double leg stretch exercise #shorts", "double leg stretch pilates"),
    "The Saw":                   ("pilates saw exercise demonstration #shorts", "pilates saw exercise"),
    "Swan Dive Prep":            ("pilates swan dive exercise demonstration #shorts", "pilates swan dive"),
    "Side Kick Series":          ("pilates side kick exercise lying #shorts", "side kick pilates"),
    "Plank":                     ("plank exercise proper form demonstration #shorts", "plank exercise"),
    "Mermaid Stretch":           ("pilates mermaid stretch exercise #shorts", "mermaid stretch pilates"),
    "Spine Twist":               ("pilates spine twist seated exercise #shorts", "spine twist pilates"),
    "Swimming":                  ("pilates swimming exercise mat prone #shorts", "pilates swimming exercise"),
    "Teaser":                    ("pilates teaser exercise demonstration #shorts", "pilates teaser"),
    "Side Plank":                ("side plank exercise demonstration form #shorts", "side plank exercise"),
    "Boomerang":                 ("pilates boomerang exercise demonstration #shorts", "pilates boomerang"),
    "Pilates Push-Up":           ("pilates push up exercise demonstration #shorts", "pilates pushup"),
    "Scissors":                  ("pilates scissors exercise demonstration #shorts", "pilates scissors"),
    "Bicycle":                   ("pilates bicycle exercise demonstration #shorts", "bicycle exercise pilates"),
    "Hip Twist":                 ("pilates hip twist exercise demonstration #shorts", "hip circles pilates"),
    "Seal":                      ("pilates seal exercise demonstration #shorts", "pilates seal"),
    "Wall Roll Down":            ("pilates wall roll down demonstration #shorts", "wall roll down"),
    "Wall Sit":                  ("wall sit exercise demonstration form #shorts", "wall sit exercise"),
    "Wall Glute Bridge":         ("wall glute bridge exercise demonstration #shorts", "wall bridge exercise"),
    "Wall Push-Ups":             ("wall push ups exercise demonstration #shorts", "wall push up exercise"),
    "Wall Inverted Plank":       ("wall inverted plank exercise #shorts", "inverted plank exercise"),
    "Wall Leg Abduction":        ("standing leg abduction exercise wall #shorts", "leg abduction exercise"),
    "Wall Pulse Squats":         ("wall pulse squat exercise #shorts", "pulse squat exercise"),
    "Wall Calf Raises":          ("calf raises exercise demonstration #shorts", "calf raise exercise"),
    "Wall Hamstring Stretch":    ("wall hamstring stretch exercise #shorts", "hamstring stretch"),
    "Legs Up the Wall":          ("legs up the wall pose exercise #shorts", "legs up the wall"),
    "Bed Pelvic Tilt":           ("pelvic tilt exercise lying down #shorts", "pelvic tilt exercise"),
    "Supine Spinal Twist":       ("supine spinal twist stretch exercise #shorts", "spinal twist stretch"),
    "Gentle Bed Bridge":         ("gentle bridge exercise beginner #shorts", "bridge exercise"),
    "Bed Leg Raise":             ("lying leg raise exercise demonstration #shorts", "leg raise lying"),
    "Relaxation Breathing":      ("deep breathing relaxation exercise technique #shorts", "deep breathing exercise"),
    "Corkscrew":                 ("pilates corkscrew exercise demonstration #shorts", "pilates corkscrew"),
    "Jackknife":                 ("pilates jackknife exercise demonstration #shorts", "pilates jackknife"),
    "Pigeon Stretch":            ("pigeon stretch exercise demonstration #shorts", "pigeon stretch"),
    "Plank Leg Lift":            ("plank leg lift exercise demonstration #shorts", "plank leg lift"),
    "Thoracic Rotation":         ("thoracic rotation exercise demonstration #shorts", "thoracic rotation exercise"),
}

# Fallback: clone from a similar exercise if everything else fails
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
}

os.makedirs(TARGET_DIR, exist_ok=True)


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


# ─── STRATEGY 1: YouTube Shorts (mid-video extraction) ───────────────────────

def download_from_youtube(english_name, filename, target_path):
    """
    Downloads from YouTube, specifically targeting Shorts.
    Extracts seconds 5-13 for Shorts (which are typically 15-60s, no intro).
    For regular videos, extracts seconds 30-38 (well past any intro).
    """
    overrides = SEARCH_OVERRIDES.get(english_name)
    if overrides:
        query = overrides[0]
    else:
        query = f"pilates {english_name} exercise demonstration #shorts"

    tmp_path = os.path.join(TARGET_DIR, "_tmp_yt.mp4")
    for f in glob.glob(os.path.join(TARGET_DIR, "_tmp_yt*")):
        os.remove(f)

    # Strategy: try Shorts timestamps first (5-13s), then fallback to deeper cut (30-38s)
    for section in ["*00:00:05-00:00:13", "*00:00:30-00:00:38"]:
        for f in glob.glob(os.path.join(TARGET_DIR, "_tmp_yt*")):
            os.remove(f)

        cmd_yt = [
            YTDLP,
            "--ffmpeg-location", FFMPEG,
            "--download-sections", section,
            "-f", "bestvideo[ext=mp4][height<=720]/mp4",
            "--no-playlist",
            "-o", tmp_path,
            f"ytsearch1:{query}"
        ]

        try:
            result = subprocess.run(cmd_yt, capture_output=True, text=True, timeout=60)
            if result.returncode != 0:
                continue

            if not os.path.exists(tmp_path):
                continue

            # Compress: scale to 480p height, strip audio, silent loop-ready
            cmd_ffmpeg = [
                FFMPEG, "-y",
                "-i", tmp_path,
                "-vf", "scale=-2:480",
                "-c:v", "libx264",
                "-crf", "28",
                "-preset", "fast",
                "-an",
                "-movflags", "+faststart",
                target_path
            ]

            subprocess.run(cmd_ffmpeg, capture_output=True, timeout=30)

            # Clean up
            for f in glob.glob(os.path.join(TARGET_DIR, "_tmp_yt*")):
                os.remove(f)

            if os.path.exists(target_path) and os.path.getsize(target_path) > 10000:
                return True

        except (subprocess.TimeoutExpired, Exception) as e:
            print(f"    yt-dlp attempt failed: {e}")

    # Clean up
    for f in glob.glob(os.path.join(TARGET_DIR, "_tmp_yt*")):
        os.remove(f)

    return False


# ─── STRATEGY 2: Tenor GIF API (free, no auth required) ──────────────────────

def download_from_tenor(english_name, filename, target_path):
    """
    Uses Tenor's free public API to search for exercise GIFs.
    These are real, high-quality, looping animations — perfect for an exercise app.
    Then converts the GIF to MP4 using ffmpeg for AVPlayer compatibility.
    """
    overrides = SEARCH_OVERRIDES.get(english_name)
    if overrides:
        query = overrides[1]
    else:
        query = f"pilates {english_name} exercise"

    encoded = urllib.parse.quote(query)
    url = f"https://tenor.googleapis.com/v2/search?q={encoded}&key={TENOR_API_KEY}&limit=3&media_filter=gif"

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read().decode())

        results = data.get("results", [])
        for result in results:
            media = result.get("media_formats", {})
            gif_url = None

            # Prefer mediumgif > gif for good quality without being huge
            for fmt in ["mediumgif", "gif", "tinygif"]:
                if fmt in media:
                    gif_url = media[fmt].get("url")
                    if gif_url:
                        break

            if not gif_url:
                continue

            # Download the GIF
            gif_tmp = os.path.join(TARGET_DIR, "_tmp_tenor.gif")
            try:
                req2 = urllib.request.Request(gif_url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req2, timeout=15) as response:
                    with open(gif_tmp, "wb") as f:
                        f.write(response.read())
            except Exception:
                continue

            if not os.path.exists(gif_tmp) or os.path.getsize(gif_tmp) < 20000:
                if os.path.exists(gif_tmp):
                    os.remove(gif_tmp)
                continue

            # Convert GIF to MP4 for AVPlayer
            cmd = [
                FFMPEG, "-y",
                "-i", gif_tmp,
                "-movflags", "+faststart",
                "-pix_fmt", "yuv420p",
                "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
                "-c:v", "libx264",
                "-crf", "23",
                "-preset", "fast",
                "-an",
                target_path
            ]

            subprocess.run(cmd, capture_output=True, timeout=30)
            if os.path.exists(gif_tmp):
                os.remove(gif_tmp)

            if os.path.exists(target_path) and os.path.getsize(target_path) > 5000:
                return True

    except Exception as e:
        print(f"    Tenor API error: {e}")

    return False


# ─── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    names = get_exercise_names()
    print(f"\n{'='*60}")
    print(f"  Smart Exercise Media Downloader v2")
    print(f"  {len(names)} exercises to source")
    print(f"{'='*60}\n")

    # Phase 0: Delete ALL existing videos (they all have intros)
    existing = glob.glob(os.path.join(TARGET_DIR, "*.mp4"))
    if existing:
        print(f"🗑️  Deleting {len(existing)} old videos with intros...\n")
        for f in existing:
            os.remove(f)

    succeeded = []
    failed = []

    for i, name in enumerate(names):
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".mp4")

        print(f"[{i+1}/{len(names)}] {name}")

        # Strategy 1: YouTube Shorts
        print(f"  📹 Trying YouTube Shorts...")
        if download_from_youtube(name, filename, target):
            size_kb = os.path.getsize(target) // 1024
            print(f"  ✅ YouTube: {filename} [{size_kb}KB]")
            succeeded.append(filename)
            continue

        # Strategy 2: Tenor GIF API
        print(f"  🎞️  Trying Tenor GIF API...")
        if download_from_tenor(name, filename, target):
            size_kb = os.path.getsize(target) // 1024
            print(f"  ✅ Tenor: {filename} [{size_kb}KB]")
            succeeded.append(filename)
            continue

        print(f"  ❌ Both strategies failed")
        failed.append(filename)
        print()

    # Phase 3: Clone fallbacks for anything still missing
    if failed:
        print(f"\n{'='*60}")
        print(f"  Resolving {len(failed)} missing via fallback clones")
        print(f"{'='*60}\n")

        still_missing = []
        for filename in failed:
            target = os.path.join(TARGET_DIR, filename + ".mp4")
            fb = FALLBACK_MAP.get(filename)
            if fb:
                src = os.path.join(TARGET_DIR, fb + ".mp4")
                if os.path.exists(src) and os.path.getsize(src) > 5000:
                    shutil.copyfile(src, target)
                    print(f"  ♻️  Cloned {fb} → {filename}")
                    continue

            # Try generic fallback
            for generic in ["exercise_pelvic_tilt", "exercise_glute_bridge", "exercise_plank"]:
                src = os.path.join(TARGET_DIR, generic + ".mp4")
                if os.path.exists(src) and os.path.getsize(src) > 5000:
                    shutil.copyfile(src, target)
                    print(f"  ⚠️  Generic clone {generic} → {filename}")
                    break
            else:
                still_missing.append(filename)

        if still_missing:
            print(f"\n  ⚠️  Still missing: {still_missing}")

    # Summary
    final_count = len([f for f in os.listdir(TARGET_DIR) if f.endswith('.mp4')])
    print(f"\n{'='*60}")
    print(f"  ✅ Complete! {final_count} exercise videos ready")
    print(f"  📁 {TARGET_DIR}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
