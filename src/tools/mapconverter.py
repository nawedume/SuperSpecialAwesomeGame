from scipy import misc


def z():
    image = misc.imread("map2.png", mode='RGB')

    count = 0
    for row in range(0, 120, 8):
        print("20'd%02d: map2[%d] = 20'b" % (count, count), end='')
        for block in range(0, 160, 8):
            if (image[row][block][0] == 0xa9 or image[row][block][0] == 0x41):
                print(1, end='')
            else:
                print(0, end='')
        
        print(';')
        count += 1

if __name__ == '__main__':
    z()