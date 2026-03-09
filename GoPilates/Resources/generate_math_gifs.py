import os
import re
import math
from PIL import Image, ImageDraw
import imageio

BASE_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates"
MODELS_FILE = os.path.join(BASE_DIR, "Models", "Exercise.swift")
TARGET_DIR = os.path.join(BASE_DIR, "Resources", "ExerciseGIFs")

if not os.path.exists(TARGET_DIR):
    os.makedirs(TARGET_DIR)

# Aesthetic Theme
BG_COLOR = (253, 226, 219) # Champagne Blush FDE2DB
SKIN = (250, 211, 182)     # FAD3B6
BRA = (255, 90, 146)       # Hot Pink FF5A92
LEGGINGS = (55, 26, 73)    # Deep Violet 371A49
MAT = (221, 178, 99)       # Gold DDB263
WALL = (245, 215, 205)

WIDTH, HEIGHT = 400, 400
FPS = 30
DURATION = 1.0  # seconds per loop

# Skeleton Base Proportions
HEAD_R = 14
TORSO_L = 45
THIGH_L = 50
CALF_L = 48
ARM_L = 35
FOREARM_L = 32

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

def get_joint(x, y, length, angle):
    # Angle in degrees. 0 is straight down, 90 is right, -90 is left.
    rad = math.radians(angle)
    return x + length * math.sin(rad), y + length * math.cos(rad)

def draw_capsule(draw, pt1, pt2, width, color):
    draw.line([pt1, pt2], fill=color, width=width)
    r = width / 2
    draw.ellipse([pt1[0]-r, pt1[1]-r, pt1[0]+r, pt1[1]+r], fill=color)
    draw.ellipse([pt2[0]-r, pt2[1]-r, pt2[0]+r, pt2[1]+r], fill=color)

def render_frame(args):
    """
    args contains:
    cx, cy: root coordinates (usually hip)
    torso, head, thigh_L, calf_L, thigh_R, calf_R, arm, forearm (angles in deg)
    """
    img = Image.new('RGB', (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Draw Yoga Mat (centered)
    draw.rectangle([60, 260, 340, 268], fill=MAT, outline=MAT)
    
    # If it's a wall exercise, draw a wall on the left
    if args.get('wall', False):
        draw.rectangle([50, 50, 60, 268], fill=WALL)

    cx, cy = args['cx'], args['cy']
    
    # Compute joints
    neck_x, neck_y = get_joint(cx, cy, TORSO_L, args['torso'])
    head_x, head_y = get_joint(neck_x, neck_y, HEAD_R*1.5, args.get('head', args['torso']))
    
    kneeL_x, kneeL_y = get_joint(cx, cy, THIGH_L, args['thigh_L'])
    ankleL_x, ankleL_y = get_joint(kneeL_x, kneeL_y, CALF_L, args['calf_L'])
    
    kneeR_x, kneeR_y = get_joint(cx, cy, THIGH_L, args['thigh_R'])
    ankleR_x, ankleR_y = get_joint(kneeR_x, kneeR_y, CALF_L, args['calf_R'])
    
    shoulder_x, shoulder_y = get_joint(cx, cy, TORSO_L * 0.85, args['torso'])
    elbow_x, elbow_y = get_joint(shoulder_x, shoulder_y, ARM_L, args['arm'])
    wrist_x, wrist_y = get_joint(elbow_x, elbow_y, FOREARM_L, args['forearm'])
    
    # Draw order (Z-index back to front)
    # Right Leg (back)
    draw_capsule(draw, (cx, cy), (kneeR_x, kneeR_y), 18, LEGGINGS)
    draw_capsule(draw, (kneeR_x, kneeR_y), (ankleR_x, ankleR_y), 14, SKIN)
    
    # Left Leg (front)
    draw_capsule(draw, (cx, cy), (kneeL_x, kneeL_y), 18, LEGGINGS)
    draw_capsule(draw, (kneeL_x, kneeL_y), (ankleL_x, ankleL_y), 14, SKIN)
    
    # Torso (Bra + Skin under)
    draw_capsule(draw, (cx, cy), (neck_x, neck_y), 24, SKIN)
    draw_capsule(draw, (cx, cy), get_joint(cx, cy, TORSO_L*0.6, args['torso']), 24, BRA)
    
    # Head
    draw.ellipse([head_x-HEAD_R, head_y-HEAD_R, head_x+HEAD_R, head_y+HEAD_R], fill=SKIN)
    # Hair bun
    draw.ellipse([head_x+5, head_y-15, head_x+15, head_y-5], fill=(80, 50, 40))
    
    # Arm (Both layered as one for 2D profile view)
    draw_capsule(draw, (shoulder_x, shoulder_y), (elbow_x, elbow_y), 12, SKIN)
    draw_capsule(draw, (elbow_x, elbow_y), (wrist_x, wrist_y), 10, SKIN)

    return img

def interpolate(val1, val2, t):
    # smooth sinusoidal interpolation t in [0, 1] goes val1 -> val2 -> val1
    phase = t * 2 * math.pi
    # map cos from 1 to -1 to: 0 to 1 back to 0
    factor = (1 - math.cos(phase)) / 2
    return val1 + factor * (val2 - val1)

def build_animation(name):
    frames = []
    
    # Categorize exactly matching app domain
    low = name.lower()
    
    base_cx, base_cy = 200, 250
    wall = 'wall' in low
    
    for f in range(FPS):
        t = f / float(FPS)
        args = {
            'cx': base_cx, 'cy': base_cy,
            'torso': 180, 'head': 180,
            'thigh_L': 90, 'calf_L': 90,
            'thigh_R': 90, 'calf_R': 90,
            'arm': 0, 'forearm': 0,
            'wall': wall
        }
        
        if 'hund' in low or 'breath' in low or 'bed' in low: # Supine Flexion
            args['cy'] = 250
            args['torso'] = 260
            args['head'] = 250
            args['thigh_L'] = 90
            args['calf_L'] = 90
            args['thigh_R'] = 90
            args['calf_R'] = 90
            # arm pumps
            args['arm'] = interpolate(90, 70, t)
            args['forearm'] = args['arm']
            
        elif 'roll' in low and not 'wall' in low: # Supine to Seated
            args['cy'] = 250
            args['thigh_L'] = 90
            args['thigh_R'] = 90
            args['calf_L'] = 90
            args['calf_R'] = 90
            args['torso'] = interpolate(270, 180, t)
            args['head'] = args['torso'] - 10
            args['arm'] = args['torso'] + 90
            args['forearm'] = args['arm']

        elif 'plank' in low or 'push' in low: # Prone support
            args['cx'] = 220
            args['cy'] = 230
            args['torso'] = 80
            args['head'] = 80
            args['thigh_L'] = 260
            args['calf_L'] = 260
            args['thigh_R'] = 260
            args['calf_R'] = 260
            # pushup dip
            args['cy'] = interpolate(230, 245, t)
            args['arm'] = interpolate(190, 140, t)
            args['forearm'] = interpolate(190, 220, t)
            
        elif 'swan' in low or 'swim' in low or 'kick' in low: # Prone Ext
            args['cy'] = 250
            args['torso'] = interpolate(90, 60, t)
            args['head'] = args['torso']
            args['thigh_L'] = interpolate(270, 250, t)
            args['calf_L'] = args['thigh_L']
            args['thigh_R'] = interpolate(270, 290, t)
            args['calf_R'] = args['thigh_R']
            args['arm'] = 90
            args['forearm'] = 90

        elif 'side' in low or 'mermaid' in low: # Side lying/kneeling
            args['cx'] = 200
            args['cy'] = 250
            args['torso'] = 180
            args['head'] = 180
            args['thigh_R'] = 90
            args['calf_R'] = 90
            args['thigh_L'] = interpolate(90, 60, t) # Lifting leg
            args['calf_L'] = args['thigh_L']
            args['arm'] = 270
            args['forearm'] = 270

        elif wall: # Standing near wall
            args['cx'] = 120
            args['cy'] = 180
            args['torso'] = 0
            args['head'] = 0
            if 'squat' in low or 'sit' in low:
                args['cy'] = interpolate(150, 200, t)
                args['thigh_L'] = interpolate(0, 90, t)
                args['calf_L'] = 0
                args['thigh_R'] = args['thigh_L']
                args['calf_R'] = 0
            else:
                args['thigh_L'] = interpolate(0, 90, t) # generic wall kick
                args['calf_L'] = args['thigh_L']
                args['thigh_R'] = 0
                args['calf_R'] = 0
            args['arm'] = 90
            args['forearm'] = 90

        else: # Generic seated V-sit (Teaser, Saw, Balance...)
            args['cx'] = 200
            args['cy'] = 250
            args['torso'] = interpolate(220, 240, t)
            args['head'] = args['torso']
            args['thigh_L'] = interpolate(320, 300, t)
            args['calf_L'] = args['thigh_L']
            args['thigh_R'] = args['thigh_L']
            args['calf_R'] = args['thigh_L']
            args['arm'] = interpolate(280, 270, t)
            args['forearm'] = args['arm']

        frames.append(render_frame(args))
        
    return frames

def main():
    names = get_exercise_names()
    print(f"Generating mathematically perfect bespoke geometry GIFs for {len(names)} exercises...")
    
    for name in names:
        filename = format_filename(name)
        target = os.path.join(TARGET_DIR, filename + ".gif")
        
        frames = build_animation(name)
        # Duration per frame is 1.0 / FPS
        imageio.mimsave(target, frames, format='GIF', duration=1.0/FPS, loop=0)
        print(f"✅ Rendered: {filename}.gif")
        
    print(f"\n✅ All {len(names)} SVGs generated mathematically. Total items: {len(os.listdir(TARGET_DIR))}")

if __name__ == "__main__":
    main()
