import re
import json

PB_FILE = "/Users/lorddecay/.gemini/antigravity/conversations/0d06004f-f208-436e-9a6e-0579e5b65f25.pb"
OUT_DIR = "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/GoPilates/Resources/SVGAnimations_Recovered"

import os
if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

with open(PB_FILE, "rb") as f:
    content = f.read().decode('utf-8', errors='ignore')

# The tool call usually looks like "write_to_file" or "default_api:write_to_file" with JSON arguments
# OR it's just a raw text block. Let's look for known markers.
# We know the files are "engine_v2.py" and "generate_all_v2.py"

# Try to find class EngineV2 or similar
for match in re.finditer(r'(import math.*?def render_svg.*?)(?=\n\n\n|\n[A-Za-z_]+ =)', content, re.DOTALL):
    pass
    
# Better approach: Extract all code blocks that might be the python files
engine_matches = re.findall(r'(```python\nimport math.*?engine_v2.*?```)', content, re.DOTALL | re.IGNORECASE)
if not engine_matches:
    engine_matches = re.findall(r'(import math\n.*?def get_svg_arc.*?)```', content, re.DOTALL)

# Let's just dump chunks containing "def get_svg_arc"
blocks = content.split('TargetFile\x12')
print(f"Found {len(blocks)} tool calls.")
for i, b in enumerate(blocks):
    if 'engine_v2.py' in b:
        with open(f"{OUT_DIR}/engine_v2_extract_{i}.txt", "w") as out:
            out.write(b[:100000]) # write the first 100k chars
    if 'generate_all_v2.py' in b:
        with open(f"{OUT_DIR}/generate_all_v2_extract_{i}.txt", "w") as out:
            out.write(b[:100000])

print("Extraction script complete.")
