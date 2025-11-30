from PIL import Image

n = Image.new("RGBA", (96, 304))
o = Image.open(input("SMM2 tileset path: "))
print("Putting everything together...")

def put(x1: int, y1: int, x2: int, y2: int):
    n.paste(o.crop((x1, y1, x1 + 16, y1 + 16)), (x2 * 16, y2 * 16))

# simple edges
put(35, 256, 0, 0)
put(69, 256, 5, 0)
put(171, 256, 5, 5)
put(137, 256, 0, 5)

put(52, 256, 1, 0)
put(18, 205, 2, 0)
put(35, 205, 3, 0)
put(52, 205, 4, 0)

put(120, 256, 5, 1)
put(222, 205, 5, 2)
put(239, 205, 5, 3)
put(256, 205, 5, 4)

put(154, 256, 1, 5)
put(120, 205, 2, 5)
put(137, 205, 3, 5)
put(154, 205, 4, 5)

put(86, 256, 0, 1)
put(171, 205, 0, 2)
put(188, 205, 0, 3)
put(205, 205, 0, 4)

# simple middle tiles
put(103, 256, 1, 1)
put(69, 205, 2, 1)
put(86, 205, 3, 1)
put(103, 205, 4, 1)

# vertical pillar
put(69, 222, 5, 7)
put(86, 222, 5, 8)
put(103, 222, 5, 9)

# horizontal pillar
put(18, 222, 0, 6)
put(35, 222, 1, 6)
put(239, 188, 2, 6)
put(256, 188, 3, 6)
put(1, 205, 4, 6)
put(52, 222, 5, 6)

# single tile
put(1, 222, 5, 10)

# fat pillar
put(137, 188, 1, 2)
put(154, 188, 2, 2)
put(171, 188, 1, 3)
put(188, 188, 2, 3)
put(205, 188, 1, 4)
put(222, 188, 2, 4)

# tri-inward-corners
put(188, 239, 3, 2)
put(171, 239, 4, 2)
put(154, 239, 3, 3)
put(137, 239, 4, 3)

# diagonal inward corners
put(1, 256, 3, 4)
put(18, 256, 4, 4)

# advanced corner box
put(171, 222, 0, 7)
put(154, 222, 4, 7)
put(120, 222, 4, 11)
put(137, 222, 0, 11)

put(205, 222, 1, 7)
put(222, 222, 4, 8)
put(188, 222, 1, 11)
put(239, 222, 0, 8)

put(69, 239, 2, 7)
put(18, 239, 4, 9)
put(103, 239, 2, 11)
put(1, 239, 0, 9)

put(86, 239, 3, 7)
put(52, 239, 4, 10)
put(120, 239, 3, 11)
put(35, 239, 0, 10)

put(188, 256, 2, 9)
put(205, 256, 3, 9)
put(222, 256, 2, 10)
put(239, 256, 3, 10)

put(239, 239, 2, 8)
put(256, 239, 3, 8)
put(205, 239, 1, 9)
put(222, 239, 1, 10)

put(256, 222, 1, 8)

print("Almost there...")

# top slopes
put(1, 409, 0, 12)
put(1, 426, 0, 13)
put(18, 409, 1, 12)
put(18, 426, 1, 13)

# bottom slopes
put(1, 443, 2, 12)
put(1, 460, 2, 13)
put(18, 443, 3, 12)
put(18, 460, 3, 13)

# floating slopes
put(35, 409, 4, 12)
put(35, 426, 4, 13)
put(52, 409, 5, 12)
put(52, 426, 5, 13)

# inward corner with slope corner, diagonal
put(256, 528, 0, 14)
put(239, 528, 1, 14)
put(256, 477, 0, 15)
put(239, 477, 1, 15)

# horizontal ground with slope corner
put(86, 460, 2, 14)
put(69, 460, 3, 14)
put(86, 443, 2, 15)
put(69, 443, 3, 15)

# vertical ground with slope corner
put(154, 460, 4, 14)
put(137, 460, 5, 14)
put(154, 443, 4, 15)
put(137, 443, 5, 15)

# inward corner with slope corner, straight
put(188, 460, 0, 16)
put(171, 460, 1, 16)
put(188, 443, 0, 17)
put(171, 443, 1, 17)

# 2 inward corners with slope corner
put(222, 460, 2, 16)
put(205, 460, 3, 16)
put(222, 443, 2, 17)
put(205, 443, 3, 17)

# vertical ground with slope corner and inward corner
put(256, 460, 4, 16)
put(239, 460, 5, 16)
put(256, 443, 4, 17)
put(239, 443, 5, 17)

# slopes with inward corner
put(35, 443, 0, 18)
put(52, 460, 1, 18)
put(35, 460, 2, 18)
put(52, 443, 3, 18)

print("Generated!")

n.save(input("Where should I put the result? "))
print("Successfully saved")