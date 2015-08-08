def CreateRegList(procString, regList, smallRegList, newList):
    for register in regList:
        if register in procString:
            newList.append(register)
    
    for register in smallRegList:
        if register in procString and register[:1] + "x" not in newList:
            register = register[:1]
            register = register + "x"
            newList.append(register)
        if register in procString and register[:1] + "x" in newList:
            newList.remove(register)
            
    return newList

def main():
    registersList = ["ax", "ah", "al", "bx", "bh", "bl", "cx", "ch", "cl", "dx", "dh", "dl"]
    smallRegistersList = ["ah", "al", "bh", "bl", "ch", "cl", "dh", "dl"]
    currentRegistersList = []
    d = {}
    fileString = open(r"C:\Users\Barak\Documents\TASM\BIN\Notepad--\a.asm", "r").read()
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
        currentRegistersList.clear()
        procSegSlice = procSegSlice[endingOfProc+4:finalIndex]
        beginningOfProc = procSegSlice.find("proc")
        endingOfProc = procSegSlice.find("endp")
        if endingOfProc == -1 or beginningOfProc == -1:
            break
        
    print(d)
    
if __name__ == "__main__":
    main()