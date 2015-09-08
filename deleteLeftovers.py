from os import remove
from glob import glob


def main():
    file_extensions = ["*.TXT", "*.DOC", "*.ODT", "*.RTF"]
    for extension in file_extensions:
        for file in glob(extension):
            remove(file)


if __name__ == "__main__":
    main()
