# Live Block Mutation Testing for Commercial Cyber-Physical Sysytem Development Tool Chain

We are investigating live block mutation of commercial cyber-physical system development tool chains (e.g. MATLAB/Simulink). We present following three independant tools in this repository:

- [CPS Profiling](+covexp/)
- [CPS Mutation](NewMutator/)
- [Differential Testing](+difftest/)

## RQ3 Bug

Here we list all the bug in  article LION RQ3:

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

## Time Resource Consumption Analysis Experiment

Due to space constraints, we provide the time resource consumption analysis here. LION uses the number of mutation points (\(k\)) and the number of blocks to be generated per mutation point (\(N\)) as inputs to generate Simulink model variants. These parameters significantly impact LION’s mutation time and efficiency. To analyze their effects, we used SLforge to generate a set of seed Simulink models and employed LION to mutate them under different configurations. Since \(k=10\) and \(N=5\) are LION's default settings (as established in RQ1), we applied a controlled variable method for parameter impact analysis. The specific procedure is as follows:

1. **Fix \(N=5\)** and vary the number of mutation points (\(k\)) as 1, 5, 10, 15, and 20.  
2. **Fix \(k=10\)** and set \(N\) to 1, 5, 10, 20, and 50.  

For each combination of settings, we evaluated the mutation time and mutation success rate:  

- **Mutation time**: The total time required to generate Simulink model variants. Shorter mutation times indicate that LION can generate more seed Simulink model variants within a given time frame.  
- **Mutation success rate**: The ratio of Simulink model variants successfully executed by Simulink among all generated variants. A higher mutation success rate implies that most generated Simulink model variants are valid.  
### TABLEⅠImpact of the Number of Mutation Points (\(k\))

| \(N=5\)         | \(k=1\) | \(k=5\) | \(k=10\) | \(k=15\) | \(k=20\) |
|------------------|---------|---------|----------|----------|----------|
| Mutation Time (hours) | 39.20   | 38.30   | 36.69    | 40.67    | 39.25    |
| Mutation Success Rate | 0.97    | 0.66    | 0.45     | 0.30     | 0.21     |

### TABLEⅡ Impact of the Number of New Blocks (\(N\))

| \(k=10\)      | \(N=1\) | \(N=5\) | \(N=10\) | \(N=20\) | \(N=50\) |
|------------------|---------|---------|----------|----------|----------|
| Mutation Time (hours) | 36.70   | 36.69   | 35.38    | 41.66    | 38.09    |
| Mutation Success Rate | 0.46    | 0.45    | 0.44     | 0.43     | 0.40     |

Tables I and II illustrate the impact of these two parameters:  

- **Mutation time**: The mutation times across different configurations were similar, ranging from 36.70 to 41.66 hours. Mutation time is primarily influenced by the total number of new blocks to be generated (\(N \times k\)). Because the MCMC sampling strategy only considers one-step transition probabilities to generate blocks, the time required to generate a single block is minimal. Consequently, LION efficiently generates Simulink model variants even as the total number of new blocks increases.  

- **Mutation success rate**: As the number of mutation points and new blocks increases, the mutation success rate decreases. However, increasing the number of blocks generated per mutation point results in only a slight reduction in mutation success rate. This demonstrates that the MCMC sampling strategy can consistently generate valid block sequences, achieving a mutation success rate between 0.42 and 0.47 (when \(k=10\)). In contrast, increasing the number of mutation points leads to a significant drop in the mutation success rate. This is expected, as LION must generate multiple block sequences, each with a stable mutation success rate.




## Requirements

MATLAB R2021b with default Simulink toolboxes

## Installation

Please use `git` to properly install all third-party dependencies:

    git clone <REPO URL>
    cd <REPO>
    git submodule update --init
    matlab # Opens MATLAB

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



