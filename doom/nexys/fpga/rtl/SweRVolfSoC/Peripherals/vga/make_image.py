from PIL import Image

def rgb444(r, g, b):
    """Convert 8-bit R, G, B into 12-bit RGB444"""
    return ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)

def rgb444_word(rgb12):
    """Place 12-bit RGB444 in LSB of 32-bit word"""
    return rgb12 & 0xFFF

# === CONFIGURATION ===
image_path = "doom_320x200.png"  # Make sure it's 320x200 and uses a palette
fb_output = "init_fb.mem"
pal_output = "init_pal.mem"

# === LOAD IMAGE ===
img = Image.open(image_path).convert("P")  # ensure it's palette mode
width, height = img.size
pixels = list(img.getdata())
palette = img.getpalette()  # 768 values (256*3)

# === GENERATE FRAMEBUFFER MEMORY ===
with open(fb_output, "w") as f:
    for i in range(0, len(pixels), 4):
        # Pack 4 pixels into one 32-bit word: byte0 = first pixel
        p = pixels[i:i+4]
        while len(p) < 4:
            p.append(0)  # pad if needed
        word = (p[3] << 24) | (p[2] << 16) | (p[1] << 8) | p[0]
        f.write(f"{word:08x}\n")

# === GENERATE PALETTE MEMORY ===
with open(pal_output, "w") as f:
    for i in range(256):
        r = palette[3 * i]
        g = palette[3 * i + 1]
        b = palette[3 * i + 2]
        rgb12 = rgb444(r, g, b)
        word = rgb444_word(rgb12)
        f.write(f"{word:08x}\n")

