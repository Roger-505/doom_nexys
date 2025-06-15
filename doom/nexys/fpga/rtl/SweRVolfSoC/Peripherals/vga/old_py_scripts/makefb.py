width = 320
height = 200
pixels = width * height  # = 64000
words = pixels // 4      # = 16000 (since each word is 4 pixels)
word = 0

with open("init_fb.mem", "w") as f:
    for i in range(words):
        f.write(f"{(words - i - 1):08x}\n")
        word += 1
