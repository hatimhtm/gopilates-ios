import sys

with open("/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/pb_strings.txt", "r") as f:
    lines = f.readlines()

engine_lines = []
generate_lines = []

in_engine = False
in_generate = False

for i, line in enumerate(lines):
    if "class EngineV2" in line or "def get_svg_arc" in line:
        # found the start of engine v2
        if not in_engine:
            in_engine = True
            # backup slightly to catch imports
            start_idx = max(0, i - 15)
            engine_lines = lines[start_idx:]
            break

for i, line in enumerate(lines):
    if "def generate_hundred" in line or "keyframes = [" in line and "from engine_v2 import" in line:
        if not in_generate:
            in_generate = True
            start_idx = max(0, i - 20)
            generate_lines = lines[start_idx:]
            break

# Write them out roughly, we will manually clean them up
with open("/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/raw_engine.txt", "w") as f:
    f.writelines(engine_lines[:2000]) # 2000 lines should be enough for the script

with open("/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/raw_generate.txt", "w") as f:
    f.writelines(generate_lines[:5000])

print("Raw chunks written.")
