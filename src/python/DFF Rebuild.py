
import shutil
from os import listdir
from os.path import isfile, join, dirname, splitext


fileList = [ 
    f for f in listdir(dirname(__file__)) if isfile(join(dirname(__file__), f))
]

for file in fileList:
    _, ext = splitext(file)
    if ext == ".dff":
        print("Rebuilding vehicle", file, "...")
        with open(file, mode="rb") as ogFile:
            ogFile.seek(0, 2)
            numOfBytes = ogFile.tell()

            for i in range(numOfBytes):
                ogFile.seek(i)
                sample = ogFile.read(4)
                # Search for 'COL3'
                if sample == b"\x43\x4F\x4C\x33":
                    print(i)
                    ogFile.seek(i)
                    data = ogFile.read(i + numOfBytes)
                    print(data)
                    # Overwrites the file
                    #with open(file, mode="wb") as opFile:
                    #    opFile.remove(data)
                    del data[i]
            
                    break

print("\nDone.")
