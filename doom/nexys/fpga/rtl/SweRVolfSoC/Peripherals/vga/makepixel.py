width = 320
height = 200
pixels = width * height  # total pixels
words = pixels // 4      # each word holds 4 pixels (8 bits each)
word = 0

with open("boot_display.mem", "w") as f:
    for i in range(words):
        # For test: create a pattern of pixel values 0x00, 0x01, 0x02, 0x03 repeated
        # Pack into 32-bit word (little endian: lowest byte is pixel 0)
        f.write(f"{word:08x}\n")
        word += 1
