from scipy import misc
import sys

def convert(image_array):
    counter = 0

    print('''DEPTH = 4092; 
WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;

CONTENT BEGIN
    ''')

    for row in image_array:
        for pixel in row:
            for color in pixel:
                print("     %03x : %02x" % (counter, color))
                counter += 1

    print('''END;''')

if __name__ == '__main__':
    if (len(sys.argv) != 2):
        sys.stderr.write("usage: %s image" % sys.argv[0])
        exit(1)
    
    image_array = misc.imread(sys.argv[1], mode='RGB')
    convert(image_array)
