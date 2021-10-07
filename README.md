# scripts derived from Matz et al. used in our IBM review paper.
# purpose:

script to perform evolutionary simulations of population fitness 
based on previous work by Matz et al. 2020 in Global Change Biology

**the purpose of these scripts is to guide new users through non-WF models in slim.**  

For instance in a classical **Wright-Fisher** model generations are **discrete**, **non-overlapping**, individuals reproduced once and died. There is **no age structure**. All these assumptions can be relaxed in a nonWF model, allowing to simulate more realistic age structure with overlapping generations.  
In a non-WF, **migration** is a property of the individuals, as opposed to a propery of the population(s) in a classic WF model.  
In a **WF** model all individuals survive to maturity and **fitness** is a probability that a sexually mature individuals will contribute to the next generation; fitness is **_relative_** as the population size will be maintained. In **nonWF** fitness influence directly the probability of survival and is a probability that a given individual survive to maturity.  
There is many more differences that are detailed in slim manual.


## Dependencies:

**Slim** [forward simulator](https://messerlab.org/slim/)

**R** software.

## software installation for LINUX USERS:

```bash
wget http://benhaller.com/slim/SLiM.zip
unzip SLiM.zip
mkdir build
cd build
cmake ../SLiM
make slim
#then add path to bashrc or cp to bin
cd ../

```

# Quick Usage:

Running a model: 

 * **_1 choose one of the model in 01-SCRIPTS/xx_scenario_xx.sh_**

example to run all model:  
    slim -d numQTLs=500 ./01-SCRIPTS/01.scenario1_1migration_warming.sh > 02-RESULTS/scenario1.500QTLs.txt  
    slim -d numQTLs=500 01-SCRIPTS/02.scenario2_1migration_bottleneckNorth_warming.sh >02-RESULTS/scenario2.500QTLs.txt  
    slim -d numQTLs=500 01-SCRIPTS/03.scenario3_2migration_bottleneckNorth_warming.sh >02-RESULTS/scenario3.500QTLs.txt  

 * **_2 perform a graph of the results with 01-SCRIPTS/04.Figure2_code.R**   
   
  simply follow the code in the Rscript  


# Detailed Usage:
  To fill
   * **1. extract climate data from CPIM5 or from biooracle**    
   (To fill)
   
   * **2. Customize and run slim models** 
    (To fill)
   * **3. Create PNG**   
  (To fill)
   * **4. create vidéo**  
     (To fill)
     
## References:

Xuereb A, Rougemont Q, Tiffin P, Xue H, Phifer-Rixey M. (2021) Individual-based eco-evolutionary models for understanding adaptation in changing seas. Accepted.


Haller BC, Messer PW. SLiM 3: Forward Genetic Simulations Beyond the Wright-Fisher Model. Mol Biol Evol. 2019;36(3):632–7.  

Matz MV, Treml EA, Aglyamova GV, van Oppen MJH, Bay LK. Potential for rapid genetic adaptation to warming in a Great Barrier Reef coral. PLoS Genet. 2018;14(4):e1007220.  

Matz MV, Treml EA, Haller BC. Estimating the potential for coral adaptation to global warming across the Indo-West Pacific. Glob Chang Biol. 2020;26(6):3473–81.  
