from PIL import Image

# === CONFIG ===
fb_file = "init_fb.mem"
pal_file = "init_pal.mem"
output_image = "reconstructed.png"
width, height = 320, 200
pixels = []

# === Load framebuffer ===
with open(fb_file, "r") as f:
    for line in f:
        word = int(line.strip(), 16)
        # Unpack 4 pixels from the word (little-endian: lowest byte is first pixel)
        p0 = word & 0xFF
        p1 = (word >> 8) & 0xFF
        p2 = (word >> 16) & 0xFF
        p3 = (word >> 24) & 0xFF
        pixels.extend([p0, p1, p2, p3])

# Sanity check
assert len(pixels) == width * height, "Pixel count mismatch"

# === Load palette ===
palette = []
with open(pal_file, "r") as f:
    for line in f:
        val = int(line.strip(), 16) & 0xFFF  # RGB444
        r = ((val >> 8) & 0xF) * 17  # scale 0–15 to 0–255
        g = ((val >> 4) & 0xF) * 17
        b = (val & 0xF) * 17
        palette.append((r, g, b))

# Pad palette if fewer than 256 colors (shouldn’t happen, but good practice)
while len(palette) < 256:
    palette.append((0, 0, 0))

# === Create and save image ===
img = Image.new("P", (width, height))
img.putdata(pixels)
# Flatten palette: [R0,G0,B0, R1,G1,B1, ..., R255,G255,B255]
flat_palette = [c for rgb in palette for c in rgb]
img.putpalette(flat_palette)
img.save(output_image)
img.show()
