#!/bin/bash

# binaries
DVE_LTSMIN="dve2lts-mc"
PNML_LTSMIN="pnml2lts-mc"
LTSMIN=${DVE_LTSMIN}

# file extension
DVE_EXTENSION="dve"
PNML_EXTENSION="pnml"
EXTENSION=$DVE_EXTENSION

# variables
TIMEOUT_TIME="600s" # 10 minutes timeout
WORKER_LIST="1 2 4 6 8 12 16 24 32 48 64"

# misc fields
BENCHDIR=`pwd`
TMPFILE="${BENCHDIR}/test.out" # Create a temporary file to store the output
FAILFOLDER="${BENCHDIR}/failures"

# input graphs folders
TACAS_FOLDER="${BENCHDIR}/experiments/beem-gen"
SPIN_FOLDER="${BENCHDIR}/experiments/beem-orig"
MCC_FOLDER="${BENCHDIR}/experiments/mcc2015"
LTL_FOLDER=${TACAS_FOLDER}

# results
TMPFILE="${BENCHDIR}/tmp.out" # Create a temporary file to store the output
TACAS_RESULTS="${BENCHDIR}/results/results-beem-gen.csv"
SPIN_RESULTS="${BENCHDIR}/results/results-beem-orig.csv"
MCC_RESULTS="${BENCHDIR}/results/results-mcc2015.csv"
RESULTS=$TACAS_RESULTS

trap "exit" INT #ensures that we can exit this bash program

# create new output file, or append to the exisiting one
create_results() {
    output_file=${1}
    if [ ! -e ${output_file} ]
    then
        touch ${output_file}
        # Add column info to output CSV
        echo "model,alg,workers,buchi,ltl,time,date,sccs,ustates,utrans,tstates,ttrans,selfloop,claimdead,claimfound,claimsuccess,cumstack,buchisize,scclist" > ${output_file}
    fi
}

# create necessary folders and files
init() {
    if [ ! -d "${FAILFOLDER}" ]; then
      mkdir "${FAILFOLDER}"
    fi
    if [ ! -d "${BENCHDIR}/results" ]; then
      mkdir "${BENCHDIR}/results"
    fi
    touch ${TMPFILE}
    create_results ${TACAS_RESULTS}
    create_results ${SPIN_RESULTS}
    create_results ${MCC_RESULTS}
}


# test_ltsmin BASE INPUT ALG WORKERS
# e.g. test_ltsmin exit.3 exit.3_T_002.ltl 1 ndfs ba
test_ltsmin() {
    if [ ! $# = 5 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_ltsmin  BASE  INPUT  WORKERS  ALG  BUCHI"
        echo "e.g. test_ltsmin  exit.3  exit.3_T_002  1  ndfs  spotba"
        exit
    fi

    base=${1%/}
    input=${2%.ltl}
    workers=${3}
    alg=${4}
    buchi=${5}

    model="${LTL_FOLDER}/${base}/${base}.${EXTENSION}"
    ltlfile="${LTL_FOLDER}/${base}/${input}.ltl"

    echo "Running ${alg} on ${input} with ${workers} worker(s) and buchi=${buchi}"
    
    TLE=0
    # run the algorithm
    timeout ${TIMEOUT_TIME} ${LTSMIN} --state=table -s28 --strategy=${alg} --threads=${workers} --buchi-type=${buchi} --ltl-semantics=spin --ltl=${ltlfile} ${model} &> ${TMPFILE}

    if [ "$?" = "124" ]; then
        echo "timeout!"
        TLE=1
    fi
    ## analyze the results
    python parse-output.py "${input}" "${alg}" "${workers}" "${buchi}" "${FAILFOLDER}" "${TMPFILE}" "${TLE}" "${RESULTS}"
}


#time test_all_beemgen_ltsmin 1 ndfs spotba
test_all_beemgen_ltsmin() {
    if [ ! $# = 3 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_all_beemgen_ltsmin  WORKERS  ALG  BUCHI"
        echo "e.g. test_all_beemgen_ltsmin  1  ndfs  spotba"
        exit
    fi
    workers=${1}
    alg=${2}
    buchi=${3}
    
    RESULTS=$TACAS_RESULTS
    LTL_FOLDER=$TACAS_FOLDER
    LTSMIN=$DVE_LTSMIN
    EXTENSION=$DVE_EXTENSION

    for folder in `(cd ${LTL_FOLDER}; ls -d */)`
    do
        for ltl in `ls ${LTL_FOLDER}/${folder} | grep -e ".ltl"`
        do
            test_ltsmin ${folder} ${ltl} ${workers} ${alg} ${buchi}
        done
    done
}

#time test_all_beemorig_ltsmin 1 ndfs spotba
test_all_beemorig_ltsmin() {
    if [ ! $# = 3 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_all_beemorig_ltsmin  WORKERS  ALG  BUCHI"
        echo "e.g. test_all_beemorig_ltsmin  1  ndfs  spotba"
        exit
    fi
    workers=${1}
    alg=${2}
    buchi=${3}
    
    RESULTS=$SPIN_RESULTS
    LTL_FOLDER=$SPIN_FOLDER
    LTSMIN=$DVE_LTSMIN
    EXTENSION=$DVE_EXTENSION

    for folder in `(cd ${LTL_FOLDER}; ls -d */)`
    do
        for ltl in `ls ${LTL_FOLDER}/${folder} | grep -e ".ltl"`
        do
            test_ltsmin ${folder} ${ltl} ${workers} ${alg} ${buchi}
        done
    done
}


#time test_all_mcc2015_ltsmin 1 ndfs spotba
test_all_mcc2015_ltsmin() {
    if [ ! $# = 3 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_all_mcc2015_ltsmin  WORKERS  ALG  BUCHI"
        echo "e.g. test_all_mcc2015_ltsmin  1  ndfs  spotba"
        exit
    fi
    workers=${1}
    alg=${2}
    buchi=${3}

    RESULTS=$MCC_RESULTS
    LTL_FOLDER=$MCC_FOLDER
    LTSMIN=$PNML_LTSMIN
    EXTENSION=$PNML_EXTENSION

    for folder in `(cd ${LTL_FOLDER}; ls -d */)`
    do
        for ltl in `ls ${LTL_FOLDER}/${folder} | grep -e ".ltl"`
        do
            test_ltsmin ${folder} ${ltl} ${workers} ${alg} ${buchi}
        done
    done
}


# initialize
init


############################################################


for count in `seq 5`
do
  test_all_beemorig_ltsmin 64 ufscc spotba
  test_all_beemorig_ltsmin 64 cndfs spotba
  test_all_beemorig_ltsmin 64 renault spotba
  test_all_beemorig_ltsmin 64 ufscc tgba
  test_all_beemorig_ltsmin 1 ndfs spotba

  test_all_beemgen_ltsmin 64 ufscc spotba
  test_all_beemgen_ltsmin 64 cndfs spotba
  test_all_beemgen_ltsmin 64 renault spotba
  test_all_beemgen_ltsmin 64 ufscc tgba
  test_all_beemgen_ltsmin 1 ndfs spotba

  test_all_mcc2015_ltsmin 64 ufscc spotba
  test_all_mcc2015_ltsmin 64 cndfs spotba
  test_all_mcc2015_ltsmin 64 renault spotba
  test_all_mcc2015_ltsmin 64 ufscc tgba
  test_all_mcc2015_ltsmin 1 ndfs spotba
done


############################################################


# cleanup
rm ${TMPFILE}
