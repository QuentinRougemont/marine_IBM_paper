# scripts derived from Matz et al. used in our IBM review paper.
# purpose:

script to perform evolutionary simulations of population fitness 
based on previous work by Matz et al. 2020 in Global Change Biology

**the purpose of these scripts is to guide new users through non-WF models in slim.**  

There are fundamental difference between **Wright-Fisher (WF)** and **non-WF** models  
For instance in a classical **Wright-Fisher** model generations are **discrete**, **non-overlapping**, individuals reproduced once and died. There is **no age structure**. All these assumptions can be relaxed in a nonWF model, allowing to simulate more realistic age structure with overlapping generations.  
In a non-WF, **migration** is a property of the individuals, as opposed to a propery of the population(s) in a classic WF model.  
In a **WF** model all individuals survive to maturity and **fitness** is a probability that a sexually mature individuals will contribute to the next generation; fitness is **_relative_** as the population size will be maintained. In **nonWF** fitness influence directly the probability of survival and is a probability that a given individual survive to maturity.  
There is many more differences that are detailed in slim manual.


## Dependencies:

**Slim** [forward simulator](https://messerlab.org/slim/)

**R** software.

## Tested on linux but should work on mac as well. 

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
    ```
    slim -d numQTLs=500 ./01-SCRIPTS/01.scenario1_1migration_warming.sh > 02-RESULTS/scenario1.500QTLs.txt  
    slim -d numQTLs=500 01-SCRIPTS/02.scenario2_1migration_bottleneckNorth_warming.sh >02-RESULTS/scenario2.500QTLs.txt  
    slim -d numQTLs=500 01-SCRIPTS/03.scenario3_2migration_bottleneckNorth_warming.sh >02-RESULTS/scenario3.500QTLs.txt  
    ```

 * **_2 perform a graph of the results with 01-SCRIPTS/04.Figure2_code.R_**   
   
  simply follow the code in the Rscript  


# Detailed Usage:
 
   * **1. extract climate data from CPIM5 or from bio-oracle**    
   Before running slim simulations we need to extract some data. 
   Here, I simply and arbitrally extracted a set of 54 (randomly chosen) locations but these correspond broadly to the American lobster and I modified the model with this in mind.
   There's 2 approaches to extract climate data.
   * From CMIP5/CMIP6 models:  
        use `01-SCRIPTS/00.extract_cmip5_data.R`  
   * From Bio-oracle:  
        use `01-SCRIPTS/00.extract_temperature_data.R`  
       
   * Hereafter I used the data from **Bio-oracle** and modelled changed in temperature each generation based on Matz et al. 
        Yet using the **CPIM5** data temperature for each generation from 1861 to 2100 combined with the approach of Matz et al. to extrapolate in the past may be a better approach. 
   
   
   * **2. Customize and run slim models** 

we provide simple model for exploration.
    First test model with **only global warming** 
      ```
    slim -d numQTLs=500 ./01-SCRIPTS/01.scenario1_1migration_warming.sh > 02-RESULTS/scenario1.500QTLs.txt
    ```
    
Second test model with **global warming + bottleneck**  The goal of the bottleneck is to mimic expected crash in population size due to other environmental factor for which the fitness effect are complicate to model. e.g. acidification.       
    ```
    slim -d numQTLs=500 01-SCRIPTS/02.scenario2_1migration_bottleneckNorth_warming.sh >02-RESULTS/scenario2.500QTLs.txt  
    ```

This test model with **global warming + bottleneck + change in connectivity**. Again, with global change, one may expect change in connectivity among populations.
    ```
    slim -d numQTLs=500 01-SCRIPTS/03.scenario3_2migration_bottleneckNorth_warming.sh >02-RESULTS/scenario3.500QTLs.txt  
    ```
    
    To add: model with environment having several effect on fitness (e.g. warming + acidification )
    

   * **3. Create PNG**   

  Simply run the Rscript ```01-SCRIPTS/04.Figure2_code.R```  to do so.   
  
  This will produce the kind of images below.   
  
  ![example_graph](https://github.com/QuentinRougemont/marine_IBM_paper/blob/main/pictures/example.png) 

  
	we see that after these 5000 generations populations have reached a high fitness in their local environment 


   	after a few generations of warming southern populations quickly undergo a drop in fitness, while migration may help maintain northermost populations a few generation, despite the bottleneck  

   ![example_graph](https://github.com/QuentinRougemont/marine_IBM_paper/blob/main/pictures/example2.png)
  
  
  
   * **4. create vidéo**  
   
    * you need ffmpeg to create the video:  
    	sudo apt update  
	sudo apt install ffmpeg 

    * reshape the results:  
    
```bash
    
cd 02-RESULTS
for i in *txt ;
do
grep -v "#\|empty\|no" $i > ${i%.txt}.reshaped.txt ;
done
```
    
    
    then I remove the first few lines of slim output in vim
    
    * Then use the Rscripts for different models:  
    For instance this scripts:
    `01-SCRIPTS/05.create_video_bottleneck_north.R`
    
    will create the video for a model with warming and a bottleneck in the northern populations 
    External commands are used from R and works well in linux. This may need some editing for windows 

     
## References:

Xuereb A, Rougemont Q, Tiffin P, Xue H, Phifer-Rixey M. (2021) Individual-based eco-evolutionary models for understanding adaptation in changing seas. Accepted.


Haller BC, Messer PW. SLiM 3: Forward Genetic Simulations Beyond the Wright-Fisher Model. Mol Biol Evol. 2019;36(3):632–7.  

Matz MV, Treml EA, Aglyamova GV, van Oppen MJH, Bay LK. Potential for rapid genetic adaptation to warming in a Great Barrier Reef coral. PLoS Genet. 2018;14(4):e1007220.  

Matz MV, Treml EA, Haller BC. Estimating the potential for coral adaptation to global warming across the Indo-West Pacific. Glob Chang Biol. 2020;26(6):3473–81.  

Original repo: https://github.com/z0on/CoralTriangle_SLiM_model
