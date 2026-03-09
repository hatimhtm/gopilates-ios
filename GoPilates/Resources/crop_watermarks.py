import os
import subprocess
import glob

INPUT_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/FinalMedia/Videos"
OUTPUT_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/FinalMedia/CroppedVideos"

os.makedirs(OUTPUT_DIR, exist_ok=True)

mp4s = glob.glob(os.path.join(INPUT_DIR, "*.mp4"))

# Ffmpeg binary
FFMPEG = "/tmp/gif_env/bin/ffmpeg" 
# Use standard ffmpeg if available
try:
    subprocess.run(["ffmpeg", "-version"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    FFMPEG = "ffmpeg"
except Exception:
    pass

for filepath in mp4s:
    filename = os.path.basename(filepath)
    outpath = os.path.join(OUTPUT_DIR, filename)
    print(f"Cropping watermark from {filename}...")
    
    # We crop the bottom 12% to ensure the watermark is completely gone,
    # starting from the top left (x=0, y=0), keeping width iw, height ih*0.88.
    cmd = [
        FFMPEG,
        "-y",
        "-i", filepath,
        "-filter:v", "crop=iw:ih*0.88:0:0",
        "-c:v", "libx264",
        "-preset", "fast",
        "-crf", "23",
        "-c:a", "copy",
        outpath
    ]
    
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"  -> SUCCESS ({os.path.getsize(outpath) // 1024} KB)")
    except subprocess.CalledProcessError as e:
        print(f"  -> FAILED: {e}")

print("Done cropping all videos!")
