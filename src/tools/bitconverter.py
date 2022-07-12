from scipy import misc
import sys

def convert(images):
    counter = 0
    for image_array in images:
        for row in image_array:
            for pixel in row:
                for color in pixel:
                    print("     %03X : %02X;" % (counter, color))
                    counter += 1

    print("     [%03X..FFFF] : 000000;" % counter)
    print('''END;''')

if __name__ == '__main__':
    if (len(sys.argv) < 2):
        sys.stderr.write("usage: %s image" % sys.argv[0])
        exit(1)
    
    images = []
    for filename in sys.argv[1:]:
        images.append(misc.imread(filename, mode='RGB'))
   
    convert(images)
