# CR Shay   regList and smallRegList shouldn't be passed as a parameter (it's constant, see CR comment about this below)
# CR Shay   Why pass newList as a parameter and not just create a new one inside the function?
#           The reason I'm trying to minimize the amount of arguments to the function is that the more arguments a
#           function receives, it is less readable and understandable. For more info on why you should try to minimize
#           parameter count, see the functions chapter in Clean Code.
def CreateRegList(procString, regList, smallRegList, newList):
    for register in regList:
        if register in procString:
            newList.append(register)
    
    for register in smallRegList:
        # CR Shay   Why check twice if the register is in the proc string? Separate the if clauses.
        if register in procString and register[:1] + "x" not in newList:
            register = register[:1]
            # CR Shay   Why not +=, also you do this action three times (once here, and once in each if clause).
            #           Get rid of the duplication.
            register = register + "x"
            newList.append(register)
        if register in procString and register[:1] + "x" in newList:
            newList.remove(register)
            
    return newList

def main():
    # CR Shay   Seems to me like these can and should be constants that aren't function specific.
    #           Furthermore, in future scripts you could use these constants (they might be useful), so extract them
    #           to a library (module) in another file and learn how to import that file and stuff out of it.
    #           In the end, it should look something like this:
    """
    import AsmLib  # or AsmHelper or AsmModule or even just Assembly, whateven you prefer to call this library

    AsmLib.REGISTER_NAMES
    AsmLib.SMALL_REGISTER_NAMES
    """
    registersList = ["ax", "ah", "al", "bx", "bh", "bl", "cx", "ch", "cl", "dx", "dh", "dl"]
    smallRegistersList = ["ah", "al", "bh", "bl", "ch", "cl", "dh", "dl"]
    currentRegistersList = []
    d = {}
    # CR Shay   Why the magic string? This code doesn't work on my machine... :( Pass the file on which you wish
    #           to run the script as a command line argument (see https://docs.python.org/3/library/argparse.html for
    #           more info).
    fileString = open(r"D:\CODE\Barak\notepad--\source.asm", "r").read()
    # CR Shay   Extract a function which gets the file's contents (AKA fileString) and returns a list of all the procs
    #           like currentProc.
    #           Then you could write something like this:
    """
    for proc in get_all_procs(file_content):
        do_something_with_proc(proc)
    """
    beginIndex = fileString.index("proc")
    finalIndex = fileString.rindex("endp")
    procSegSlice = fileString[beginIndex:finalIndex+4]
    beginningOfProc = procSegSlice.index("proc")
    endingOfProc = procSegSlice.index("endp")
    while endingOfProc <= finalIndex:
        currentProc = procSegSlice[beginningOfProc:endingOfProc]
        currentRegistersList = CreateRegList(currentProc, registersList, smallRegistersList, currentRegistersList)
        procName = currentProc.rsplit(None, 1)[-1]
        d[procName] = currentRegistersList
        # CR Shay   The bug is caused by the code's flawed design, and is finally exposed when this line runs.
        #           Figuring out what's wrong and how to change the code to fix it is left to you as an assignment.
        #           You didn't expect it to be that easy, now did you? :)
        currentRegistersList.clear()
        procSegSlice = procSegSlice[endingOfProc+4:finalIndex]
        beginningOfProc = procSegSlice.find("proc")
        endingOfProc = procSegSlice.find("endp")
        if endingOfProc == -1 or beginningOfProc == -1:
            break
        
    print(d)
    
if __name__ == "__main__":
    main()