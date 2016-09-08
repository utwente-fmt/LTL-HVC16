
import sys
import re
import os.path
import time
import datetime
import csv
import shutil

TLE         = ""
INFILE      = ""
FAILFOLDER  = ""
OUTFILE     = ""
CORRECTFILE = ""
dict        = {}

DEBUG       = True

def printError(msg):
    global DEBUG
    if DEBUG:
        print "ERROR: {}".format(msg)

def exitparser():
    # try to print the contents to an output file
    global dict, INFILE, FAILFOLDER
    counter = 0
    while True:
        counter += 1
        failname = "{}/{}_{}_{}_{}_{}.out".format(
            FAILFOLDER,dict["model"],dict["alg"],dict["buchi"],dict["workers"],counter)
        if not (os.path.isfile(failname)):
            break
    shutil.copy2(INFILE, failname)
    # and exit the program
    sys.exit()
    

def checkfile(file):
    if not (os.path.isfile(file)):
        printError("cannot find file: {}".format(file))
        exitparser()


def parsevar(varname, line, regex):
    pattern = re.compile(regex)
    searchpattern = pattern.search(line)
    if (searchpattern):
        global dict
        if (dict.get(varname)):
            printError("multiple matches for {}".format(varname))
            exitparser()
        else:
            dict[varname] = searchpattern.group(1)


def parseerror(line, regex):
    pattern = re.compile(regex)
    searchpattern = pattern.search(line)
    if (searchpattern):
        printError(line)
        exitparser()


def parseline(line):
    parseerror(line, r"Error")
    parsevar("time",         line, r"Total exploration time ([\S]+) sec")
    parsevar("tstates",      line, r"Explored ([\S]+) states [\S]+ transitions, fanout: [\S]+")
    parsevar("ttrans",       line, r"Explored [\S]+ states ([\S]+) transitions, fanout: [\S]+")
    parsevar("sccs",         line, r"total scc count: [\s]+ ([\S]+)")
    parsevar("ustates",      line, r"unique states count: [\s]+ ([\S]+)")
    parsevar("utrans",       line, r"unique transitions count:[\s]+ ([\S]+)")
    parsevar("selfloop",     line, r"self-loop count: [\s]+ ([\S]+)")
    parsevar("claimdead",    line, r"claim dead count: [\s]+ ([\S]+)")
    parsevar("claimfound",   line, r"claim found count: [\s]+ ([\S]+)")
    parsevar("claimsuccess", line, r"claim success count: [\s]+ ([\S]+)")
    parsevar("cumstack",     line, r"cum. max stack depth: [\s]+ ([\S]+)")
    if "~" in line:
        parsevar("ltl",          line, r"Accepting cycle FOUND at depth ~([\S]+)!")
    else:
        parsevar("ltl",          line, r"Accepting cycle FOUND at depth ([\S]+)!")
    parsevar("ltl",          line, r"Accepting cycle FOUND after ([\S]+) iteration(s)!")
    #parsevar("ltl",          line, r"Writing counter example trace of length ([\S]+)")
    parsevar("buchisize",    line, r"buchi has ([\S]+) states")
    parsevar("scclist",      line, r"Printing SCC list: ([\S]+)")


def init_dict_var(varname):
    global dict
    if not (dict.get(varname)):
        dict[varname] = "-1"


def afterparse():
    global TLE, dict
    init_dict_var("sccs")
    init_dict_var("ustates")
    init_dict_var("utrans")
    init_dict_var("selfloop")
    init_dict_var("claimdead")
    init_dict_var("claimfound")
    init_dict_var("claimsuccess")
    init_dict_var("cumstack")
    init_dict_var("ltl")
    init_dict_var("buchisize")
    init_dict_var("scclist")
    if (TLE == "1"):
        if not (dict.get("time")):
            dict["time"] = "600.000"
            init_dict_var("tstates")
            init_dict_var("ttrans")


def checkitemcorrect(correct, item):
    global dict
    if not (dict.get(item)):
        printError("Cannot find {}".format(item))
        exitparser()
    if (dict[item] != correct):
        printError("{} = {} is incorrect (should be {}) ".format(item, dict[item], correct))
        exitparser()


def checkcorrect():
    global dict, CORRECTFILE
    # only check if we have a correct file
    if (os.path.isfile(CORRECTFILE)):
        f = open(CORRECTFILE, 'rb')
        reader = csv.DictReader(f)
        for row in reader:
            if (row["model"] == dict["model"]):
                # check if variables are the same
                checkitemcorrect(row["sccs"], "sccs")
                checkitemcorrect(row["utrans"], "utrans")
                checkitemcorrect(row["ustates"], "ustates")


def parsefile(file):
    f = open(file, 'r')
    for line in f:
        parseline(line)
    f.close()
    afterparse()
    #checkcorrect()


def trytoprint(varname):
    global dict
    if (dict.get(varname)):
        return dict.get(varname)
    else:
        if (varname == "time" or 
            varname == "sccs" or 
            varname == "utrans" or 
            varname == "ustates") :
            printError("cannot find {}".format(varname))
            exitparser()
        if (dict["alg"] != "ufscc"):
            return "-1"
        else:
            printError("cannot find {}".format(varname))
            exitparser()


def printtofile(outfile):
    # First line of OUTFILE should contain comma-separated info on column names
    global dict
    f = open(outfile, 'r+')
    s = f.readline().strip()
    names = s.split(",")
    output  = ""
    for name in names:
        output += trytoprint(name) + ","
    output = output[:-1] # remove last ","
    f.read() # go to the last line
    f.write("\n"+output) # write the new line
    f.close()


def printtostdout():
    # find longest key name (for formatting)
    global dict
    maxlen = 1
    for varname in dict:
        maxlen = max(maxlen, len(varname))
    # print everything to stdout
    for varname in dict:
        print varname + ":" +  " " * (maxlen+1-len(varname)) + dict[varname]


def addextra():
    # Add timestamp
    global dict
    ts = time.time()
    dict["date"] = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d.%H:%M:%S')


def main():
    global dict, INFILE, OUTFILE, FAILFOLDER, CORRECTFILE, TLE
    N_ARG = len(sys.argv)
    if (N_ARG == 8):
        dict["model"]   = str(sys.argv[1])
        dict["alg"]     = str(sys.argv[2])
        dict["workers"] = str(sys.argv[3])
        dict["buchi"]   = str(sys.argv[4])
        FAILFOLDER      = str(sys.argv[5])
        INFILE          = str(sys.argv[6])
        TLE             = str(sys.argv[7])
        checkfile(INFILE)
        parsefile(INFILE)
        addextra()
        printtostdout()
    elif (N_ARG == 9):
        dict["model"]   = str(sys.argv[1])
        dict["alg"]     = str(sys.argv[2])
        dict["workers"] = str(sys.argv[3])
        dict["buchi"]   = str(sys.argv[4])
        FAILFOLDER      = str(sys.argv[5])
        INFILE          = str(sys.argv[6])
        TLE             = str(sys.argv[7])
        OUTFILE         = str(sys.argv[8])
        checkfile(INFILE)
        checkfile(OUTFILE)
        parsefile(INFILE)
        addextra()
        printtofile(OUTFILE)
    else:
        print "ERROR: invalid command"
        print "Usage:"
        print " - python parse_output.py  MODEL  ALG  WORKERS  BUCHI  FAILFOLDER  INFILE  TLE           # writes all output to the stdout"
        print " - python parse_output.py  MODEL  ALG  WORKERS  BUCHI  FAILFOLDER  INFILE  TLE  OUTFILE  # appends the data to the OUTFILE in the same format used"


if __name__ == "__main__":
    main()
