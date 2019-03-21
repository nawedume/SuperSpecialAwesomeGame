from scipy import misc
import sys

def convert(images):
    counter = 0

    print('''DEPTH = 4096; 
WIDTH = 8;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;

CONTENT BEGIN
    ''')

    for image_array in images:
        for row in image_array:
            for pixel in row:
                for color in pixel:
                    print("     %03X : %02X;" % (counter, color))
                    counter += 1

    print("     [%03X..FFF] : 00;" % counter)
    print('''END;''')

if __name__ == '__main__':
    if (len(sys.argv) < 2):
        sys.stderr.write("usage: %s image" % sys.argv[0])
        exit(1)
    
    images = []
    for filename in sys.argv[1:]:
        images.append(misc.imread(filename, mode='RGB'))
   
    convert(images)
