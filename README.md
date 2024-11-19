# Live Block Mutation of CPS Models for Detecting Simulink Compiler Bugs

We are investigating live block mutation of commercial cyber-physical system development tool chains (e.g. MATLAB/Simulink). We present following three independant tools in this repository:

- [CPS Profiling](+covexp/)
- [CPS Mutation](NewMutator/)
- [Differential Testing](+difftest/)

## RQ2 Bug

Here we list all the bug in  article LION RQ2:

[05318668](BugFile/05318668)	S-Function Too many output arguments.</br>
[05359223](BugFile/05359223)	Compilation error prompts an unreasonable exception.</br>
[05359149](BugFile/05359149)    Equivalent mathematical function modules compile different prompts.</br>
[05370105](BugFile/05370105)    Exception in accelerate mode for if block.</br>
[05382868](BugFile/05382868)    Data results different exception of max block.</br>
[05394704](BugFile/05394704)    Min block produce incorrect results in accelerator modes with NaN input.</br>
[05407559](BugFile/05407559)    Unknown module acceleration mode is abnormal.</br>
[05416819](BugFile/05416819)    Time vector inconsistency error of DTC block.</br>
[05422544](BugFile/05422544)    Inconsistent Delay module data in different modes.</br>
[05403026](BugFile/05403026)    Zero-crossing signal exception of the min block.</br>
[05422545](BugFile/05422545)    Error in Sum module with onconsistent data result.</br>
[05411035](BugFile/05411035)    The Observer Block acceleration mode is not detected.</br>
[05445811](BugFile/05445811)    Problem of inconsistent data in the RT module.</br>
[05445813](BugFile/05445813)    Data inconsistency errors when running the Product module.</br>
[05436071](BugFile/05436071)    Ramp block is affected and produces different data in different modes.</br>
[05434051](BugFile/05434051)    Sinwave module data is inconsistent in different compilation!</br>

To see more detail about bug file , click this [BugFile](BugFile/)

## Requirements

MATLAB R2021b with default Simulink toolboxes

## Installation

Please use `git` to properly install all third-party dependencies:

    git clone <REPO URL>
    cd <REPO>
    git submodule update --init
    matlab # Opens MATLAB

## Hello, World!
### CPS Profiling  
First, you need to put the available SLforge model into the reproduce folder and enter the following statement on the MATLAB command line   

    setenv('SLSFCORPUS','<YOUR LION PROJECT URL>/reproduce')
    setenv('COVEXPEXPLORE','<YOUR LION PROJECT URL>//reproduce')   
    
Before the official profiling, you can modify the parameters according to your own needs in the covcfg.m file,then use command:   

    covexp.covcollect()

To Profiling the CPS.
### CPS Mutation 
The details of variant generation are set in the +emi/cfg.m file. After setting, use the

    emi.go() 
    
statement to generate variants
### Differential Testing 
Use

    emi.report 
    
to view the EMI differential test results of the variant model and the original model.
If you need to check out the mutation in EMI different mode result , use

    accfinddiff
    
and wait for the result in folder bugsave/
## Randomly Generated Seed Models And Compare In EMI Mode

We use the open source *SLforge* tool to generate valid Simulink models. 

We use the open source *SLEMI* tool to compare Simulink models in EMI mode. 

Although we initially forked from the project, our current version is independant of SLEMI and its predecessor SLforge.

### SLforge: Automatically Finding Bugs in a Commercial Cyber-Physical Systems Development Tool

Check out [SLforge homepage](https://github.com/verivital/slsf_randgen/wiki) for latest news, running the tools and to contribute.

### SLEMI: EMI-based Validation of Cyber-Physical System Development Tool Chain

Check out [SLEMI homepage](https://github.com/shafiul/slemi/wiki) for latest news, running the tools and to contribute.



