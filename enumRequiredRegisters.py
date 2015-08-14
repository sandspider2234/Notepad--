from asmlib import consts
from argparse import ArgumentParser


def create_reg_list(procString):
    new_list = []
    for register in consts.REGISTERS_LIST:
        if register in procString:
            new_list.append(register)

    for register in consts.SMALL_REGISTERS_LIST:
        if register in procString:
            if register[:1] + "x" not in new_list:
                new_list.remove(register)
                register = register[:1]
                register += "x"
                new_list.append(register)
            else:
                new_list.remove(register)

    new_list.sort()
    return new_list


def main():
    d = {}
    parser = ArgumentParser()
    parser.add_argument("-filename", default="source.asm",
                        help="File to be enumerated. If file is in current folder, filename only is OK. "
                             "Else, full path is required.", metavar="path")
    file_string = open(parser.parse_args().filename, "r").read()
    # CR Shay   Extract a function which gets the file's contents (AKA file_string) and returns a list of all the procs
    #           like currentProc.
    #           Then you could write something like this:
    """
    for proc in get_all_procs(file_content):
        do_something_with_proc(proc)
    """
    begin_index = file_string.index("proc")
    final_index = file_string.rindex("endp")
    proc_seg_slice = file_string[begin_index:final_index + 4]
    beginning_of_proc = proc_seg_slice.index("proc")
    ending_of_proc = proc_seg_slice.index("endp")
    while ending_of_proc <= final_index:
        current_proc = proc_seg_slice[beginning_of_proc:ending_of_proc]
        current_registers_list = create_reg_list(current_proc)
        proc_name = current_proc.rsplit(None, 1)[-1]
        d[proc_name] = current_registers_list[:]
        # CR Shay   The bug is caused by the code's flawed design, and is finally exposed when this line runs.
        #           Figuring out what's wrong and how to change the code to fix it is left to you as an assignment.
        #           You didn't expect it to be that easy, now did you? :)
        current_registers_list.clear()
        proc_seg_slice = proc_seg_slice[ending_of_proc + 4:final_index]
        beginning_of_proc = proc_seg_slice.find("proc")
        ending_of_proc = proc_seg_slice.find("endp")
        if ending_of_proc == -1 or beginning_of_proc == -1:
            break

    print(d)


if __name__ == "__main__":
    main()
