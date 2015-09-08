from AsmLib import consts
from argparse import ArgumentParser


def create_reg_list(proc_string):
    new_list = [register for register in consts.REGISTERS_LIST if register in proc_string]

    for register in consts.SMALL_REGISTERS_LIST:
        if register in proc_string:
            large_register = register[:1] + "x"
            if large_register not in new_list:
                new_list.remove(register)
                new_list.append(large_register)
            else:
                new_list.remove(register)

    new_list.sort()
    return new_list


def get_all_procs(file_string):
    proc_list = []
    begin_index = file_string.index("proc")
    final_index = file_string.rindex("endp")
    proc_seg_slice = file_string[begin_index:final_index + 4]
    beginning_of_proc = proc_seg_slice.index("proc")
    ending_of_proc = proc_seg_slice.index("endp")
    while ending_of_proc <= final_index:
        proc_list.append(proc_seg_slice[beginning_of_proc:ending_of_proc])
        proc_seg_slice = proc_seg_slice[ending_of_proc + 4:final_index]
        beginning_of_proc = proc_seg_slice.find("proc")
        ending_of_proc = proc_seg_slice.find("endp")
        if ending_of_proc == -1 or beginning_of_proc == -1:
            break
    return proc_list


def main():
    proc_dict = {}
    parser = ArgumentParser()
    parser.add_argument("-filename", default="source.asm",
                        help="File to be enumerated. If file is in current folder, filename only is OK. "
                             "Else, full path is required.", metavar="path")
    file_string = open(parser.parse_args().filename, "r").read()

    for proc in get_all_procs(file_string):
        current_registers_list = create_reg_list(proc)
        proc_name = proc.rsplit(None, 1)[-1]
        proc_dict[proc_name] = current_registers_list[:]
        current_registers_list.clear()

    print(proc_dict)


if __name__ == "__main__":
    main()
