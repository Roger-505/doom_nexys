def rgb444(r, g, b):
    """Convert 4-bit R, G, B into a 12-bit RGB444 value"""
    return ((r & 0xF) << 8) | ((g & 0xF) << 4) | (b & 0xF)

def rgb444_word(rgb12):
    """Place 12-bit RGB444 in LSB of 32-bit word"""
    return rgb12 & 0xFFF

with open("init_pal.mem", "w") as f:
    for i in reversed(range(256)):
        # Create a simple color gradient pattern:
        r = (i >> 4) & 0xF  # Top 4 bits
        g = (i >> 2) & 0xF  # Middle 4 bits
        b = i & 0x3         # Bottom 2 bits (scaled to 4-bit)
        b = b << 2 | b      # crude 2-to-4-bit scaling
        
        rgb12 = rgb444(r, g, b)
        word = rgb444_word(rgb12)
        f.write(f"{word:08x}\n")
