# from PIL import Image
# im = Image.open('Fenn.bmp')
#
# pixels = list(im.getdata())
# width, height = im.size
# pixels = [pixels[i * width:(i + 1) * width] for i in range(height)]
# print(pixels)
# X = []
# Y = []
# C = []
#
# Dic = {85: 0, 255: 1, 170: 1, 0: 0}
#
# for i, arr in enumerate(pixels):
#   for j, k in enumerate(arr):
#     if k == (0, 0, 0):
#       continue
#     else:
#       X.append(j)
#       Y.append(i)
#       C.append(Dic[k[0]]*4+Dic[k[1]]*2+Dic[k[2]])
#       if k[0] == 85 or k[0] == 255:
#         C[-1] = C[-1] + 8
#
#
# Y = [hex(i).replace("0x","") for i in Y]
# X = [hex(j).replace("0x","") for j in X]
# C = [hex(j).replace("0x","") for j in C]
#
# StrX = "PaddleX DW "
# StrY = "PaddleY DW "
# StrC = "PaddleC DB "
# for i in range(len(X)):
#     if i % 20 == 19:
#       StrX = StrX + "0"+X[i]+"h "+ "\n DW "
#       StrY = StrY + "0"+Y[i]+"h "+ "\n DW "
#       StrC = StrC + "0"+C[i]+"h "+ "\n DB "
#     else:
#       StrX = StrX + "0"+X[i]+"h, "
#       StrY = StrY + "0"+Y[i]+"h, "
#       StrC = StrC + "0"+C[i]+"h, "
# print("0" + hex(len(X)).replace("0x","") + "h")
# StrX = StrX[:-2]
# StrY = StrY[:-2]
# StrC = StrC[:-2]
#
# print(StrX)
# print(StrY)
# print(StrC)


# $im = imagecreatefrompng("vga-palette.png");
# $sx = (int) 800 / 16;
# $sy = (int) 800 / 16;
# $ox = (int) ($sx / 2);
# $oy = (int) ($sx / 2);
# for($y = 0; $y < 16; $y++) {
#     for($x = 0; $x < 16; $x++) {
#         $rgb = imagecolorat($im, $sx*$x + $ox, $sy*$y + $oy);
#         $r = ($rgb >> 16) & 0xFF;
#         $g = ($rgb >> 8) & 0xFF;
#         $b = $rgb & 0xFF;
#         $color = sprintf("%02x%02x%02x", $r, $g, $b);
#         printf("%d,%d,%d,%02x,%02x,%02x,%s\n", $r, $g, $b, $r, $g, $b, $color);
#     }
# }

from PIL import Image
im = Image.open('Hisoka.bmp')
#print(list(im.getdata()))
im2 = im.convert("P", palette=Image.ADAPTIVE, colors=256)
#print(list(im2.getdata()))
palette = im2.getpalette()
#print(palette)
#im2.save('test.bmp')
StrX = "DB "
for i in range(len(palette)):
    if i % 20 == 19:
      StrX = StrX + "0" +str(palette[i]) + "\n DB "
    else:
      StrX = StrX + "0"+str(palette[i])+", "
# print("0" + hex(len(palette)).replace("0x","") + "h")
StrX = StrX[:-2]

print(StrX)
print(len(palette))






