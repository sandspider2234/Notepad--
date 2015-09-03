from os import remove
from glob import glob

file_extensions = ["*.TXT", "*.DOC", "*.ODT"]
for extension in file_extensions:
    for file in glob(extension):
        remove(file)
