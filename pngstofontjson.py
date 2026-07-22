import os

# {
#     "type": "bitmap",
#     "file": "minecraft:font/black.png",
#     "ascent": 500,
#     "height": 2048,
#     "shift": [3.0, 50.0],
#     "chars": [
#         "\uE000"
#     ]
# },

prefix = "minecraft:font/cat/"
ascent = 40
height = 80
current_hex = 0xE000

f = open('pack/assets/minecraft/font/cat.json', 'w')

f.write("""{"providers":[""")

first = True
for file in os.listdir("pngs/"):
    if not file.endswith(".png"):
        continue

    if first:
        first = False
    else:
        f.write(",")

    mc_file = prefix + file
    json = f"""{{"type":"bitmap","file":"{mc_file}","ascent":{ascent},"height":{height},"chars":["\\u{current_hex:X}"]}}"""

    current_hex += 1 # increment hex

    f.write(json)

f.write("""]}""")

f.close()