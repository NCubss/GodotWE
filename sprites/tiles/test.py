from PIL import Image

im = Image.open("ground.png")
bands = im.split()
nim = Image.merge("RGBA", (bands[0], bands[1].transpose(Image.Transpose.FLIP_TOP_BOTTOM), bands[2].transpose(Image.Transpose.FLIP_LEFT_RIGHT), bands[3]))
nim.save("fart.png")