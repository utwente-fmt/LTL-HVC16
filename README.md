Multi-core SCC-based LTL Model Checking
===

This repository hosts the experiments and results for the paper and provides a
short guide on how to install the tools and reproduce the results.

Please note that all experiments in the paper were performed on a machine 
running Ubuntu 14.04 with 4 AMD Opteron<sup>TM</sup> 6376 processors, 
each with 16 cores, forming a total of 64 cores. There is a total of 
512GB memory available. All experiments are explicitly set up to use 64 threads,
consult `benchmark.sh` for modifying this configuration. 

Submitted and accepted to [HVC 2016], to be published in Springer LNCS.

Authors:
---

* Formal Methods and Tools, University of Twente, The Netherlands
    - Vincent Bloemen*:      [<v.bloemen@utwente.nl>](mailto:v.bloemen@utwente.nl)
    - Jaco van de Pol:       [<j.c.vandepol@utwente.nl>](mailto:j.c.vandepol@utwente.nl)

\* Supported by the 3TU.BSR project.

Abstract
---

*We investigate and improve the scalability of multi-core LTL
model checking. Our algorithm, based on parallel DFS-like SCC decomposition, 
is able to efficiently decompose large SCCs on-the-fly, which is
a difficult problem to solve in parallel.
To validate the algorithm we performed experiments on a 64-core machine. 
We used an extensive set of well-known benchmark collections
obtained from the BEEM database and the Model Checking Contest.
We show that the algorithm is competitive with the current state-of-the-art 
model checking algorithms. For larger models we observe that
our algorithm outperforms the competitors. We investigate how graph
characteristics relate to and pose limitations on the achieved speedups.*

Installation
---
If you experience any issues with the installation please consult the [LTSmin] 
website and [Spot] website for further instructions.

Firstly for Ubuntu we need to install the following dependencies:

```
$ sudo apt-get install build-essential automake autoconf libtool libpopt-dev 
zlib1g-dev zlib1g flex ant asciidoc xmlto doxygen wget git
```

### Installing Spot 2.0

1. Clone the Spot repository:
    * `$ git clone https://gitlab.lrde.epita.fr/spot/spot.git`
2. Change directory:
    * `$ cd spot`
2. Checkout the Spot 2.0 version:
    * `$ git checkout spot-2-0`
4. Get the latest modules for ltsmin:
    * `$ git submodule update --init`
5. Configure:
    * `$ ./configure --prefix=$HOME/install --disable-python`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
6. Make and install:
    * `$ make && make install`


### Installing LTSmin

1. Clone the LTSmin repository:
    * `$ git clone git@github.com:vbloemen/ltsmin.git -b next`
2. Change directory:
    * `$ cd ltsmin`
2. Checkout the version used for the paper:
    * `$ git checkout hvc16`
4. Get the latest modules for ltsmin:
    * `$ git submodule update --init`
5. Run `ltsminreconf`:
    * `$ ./ltsminreconf`
6. Configure the LTSmin build:
    * `$ ./configure --without-scoop --without-sylvan --with-spot=$HOME/install --prefix $HOME/install`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
7. Make and install:
    * `$ make && make install`


Usage
---

### Testing

To test if the tools have been successfully installed, a single benchmark can
be tested as follows:

```
$ dve2lts-mc --buchi-type=spotba experiments/beem-gen/adding.4/adding.4.dve \
--threads=2 --strategy=ufscc --ltl=experiments/beem-gen/adding.4/adding.4_F_001.ltl
```

As a result, the program output should report a counterexample similar to the following:

```
(...)
dve2lts-mc( 1/ 2): Accepting cycle FOUND at depth ~29!
(...)
```

For experiments that do not contain a counterexample (i.e. all LTL formulas 
containing `_T_` in their name), the full state space should get explored and no
accepting cycle should get reported.

### Running the benchmarks

The script `benchmark.sh` is set up to perform all benchmark experiments 5 times
on each configuration (see the bottom of the script). Note that this script uses
a timeout of 10 minutes for each experiment. Also note that running this script 
will take several days to complete, using the above-mentioned machine.

The `benchmark.sh` script provides information on the standard output regarding 
which experiment is currently being performed. Error messages, due to crashes
or timeouts are also provided on the standard output. Results are appended to 
the thee CSV files (one for each benchmark suite) in the `results` directory.

### Analyzing the benchmark results

The `results` directory contains three CSV files, obtained by performing the
`benchmark.sh` script. 

The graphs and tables in the paper were obtained from these results, using the
R script `generate-plots.R`, which can be used as follows:

```
$ Rscript generate-plots.R
```

The script will printout table contents on the standard output, and generate
scatterplot graphs in the `results/plots` directory.

[LTSmin]: http://fmt.cs.utwente.nl/tools/ltsmin/
[HVC 2016]: https://www.research.ibm.com/haifa/conferences/hvc2016/index.shtml
[Spot]: https://spot.lrde.epita.fr/


