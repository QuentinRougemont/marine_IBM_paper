// slim -d numQTLs=1000 

initialize() {
	if (exists("slimgui"))
		{
			defineConstant("numQTLs", 100);
		}
	initializeSLiMModelType("nonWF");
	defineConstant("startTime",clock()); 
	initializeSLiMOptions(preventIncidentalSelfing=T);
	defineConstant("popscale",1);                   // set to <1 for quicker runs, Mutation rate will be scaled proportionally  to keep the same theta
	defineConstant("N_offspring",5);
	initializeMutationRate(1e-05); 
        
	// age-related mortality 
        defineConstant("L", c(0.5,0.25, rep(0,60),0.25, 1));
	defineConstant("esd",0.5);	                // sd of environmental effect on fitness, on top of genetic N(0°C,0.5°C) ==> noise
	defineConstant("pl",1);			        // plasticity: SD of the fitness bell curve 
	defineConstant("mutEffect",0.02);	        // fitness effect of mutation effects at QTLs (mean=0) N(0°C,0.03°C)
	defineConstant("C", numQTLs);		        // number of QTLs
	defineConstant("N", 1);		                // number of unlinked neutral sites (for popgen)

	defineConstant("maxfit",dnorm(0.0,0.0,pl));	// height of N peak, for fitness scaling
	defineConstant("fitcushion",1e-4);      	// lowest possible fitness

	// genetic architecture is defined below:
	// neutral mutations in non-coding regions
	initializeMutationType("m1", 0.5, "f", 0.0);			// neutral
	initializeMutationType("m2", 0.5, "n", 0, mutEffect);		// thermal QTL
	initializeGenomicElementType("g1", m1, 1.0);
	initializeGenomicElementType("g2", m2, 1.0);
	m2.convertToSubstitution =F;
	initializeGenomicElement(g2,0,C-1);
	initializeGenomicElement(g1,C,C+N-1);
	initializeRecombinationRate(0.5);
	m2.mutationStackPolicy = "s"; // new mutations add to previous ones at the same locus
}

// reading the tab-delimited migration rates matrix with pop sizes on diagonal 
// sources are rows, sinks are columns
1 early() { 
	migrations=readFile("00-DATA/mig1_54.txt");
	defineConstant("npops",size(migrations));
	defineConstant("north",asInteger(size(migrations)/2));

	// reading pop sizes
	defineConstant("popsizes",readFile("00-DATA/popsize.csv"));
	
	// make our subpopulations (1/10 of final size initially), set emigration rates
	for (p in seqLen(npops)){
                //cat (popsizes[p]);
		psize=10+asInteger(popscale*asInteger(popsizes[p])/25); // size of each pop. with at least 10 ind to prevent crash
		sim.addSubpop(p, psize);
		inds=sim.subpopulations[p].individuals;          // create subpop of individuals
		inds.age = rdunif(psize, min=4, max=55);         // ade random age of the inds. 
		inds.tagF=rnorm(size(inds),0,esd);               // add ind env. effect assuming normal distribution
		ms=asFloat(strsplit(migrations[p],sep="\t"));    // migration rate between pop 
		sim.subpopulations[p].setValue("popmig", ms);
		sim.subpopulations[p].setValue("popsize",psize);
		cat(asInteger(popsizes[p])+" "+"\n");
		//cat(" "+asInteger(size(inds)+"\t"));
	}
   sim.chromosome.setMutationRate(1e-5*25);
}

// load environmental profiles: tab-delimited table with generations as columns, pops as rows. Header line must be present but what it contains is irrelevant.
1 early() { 
env=readFile("00-DATA/balanced_env54pop_sin_a_environment.txt");
	for (i in seqLen(npops)) {
		pop=sim.subpopulations[i];
		pop.setValue("env",asFloat(strsplit(env[i+1],sep="\t"))); 
	}
}

fitness(m2) { 
	// the QTLs themselves are neutral
		return 1.0;
}

// reproduction with dispersal of new individuals among subpops according to migration matrix
reproduction() {
	if(size(subpop.individuals)>1 & individual.age>4){
		if ((sim.generation>2000 & sim.generation<2005) | (sim.generation>4000 & sim.generation<4005)) {
			for (i in 1:N_offspring) { // redistribute offspring randomly
				dest = sample(sim.subpopulations, 1);
                                mate=subpop.sampleIndividuals(1,exclude=individual,minAge=5);
                                if(size(mate)>0) {
                                        dest.addCrossed(individual, mate);
                                }
			}
		}	else {
			dest = sample(sim.subpopulations, 1,weights=subpop.getValue("popmig"));	
			for (i in 1:N_offspring) { // offspring of the same cross migrate together
				mate=subpop.sampleIndividuals(1,exclude=individual,minAge=5);
				if(size(mate)>0) {
					dest.addCrossed(individual, mate);
				}
			}
		}
	}
}

// #storing individual-specific environmental noise values (so they don't change from year to year)
modifyChild() {
	child.tagF=rnorm(1,0,esd);
	return T;
}

// QTL fitness and density dependence
2: early() {
	catn("#"+sim.generation);
	deadpops=0;
	// life table based individual mortality
	for (subpop in sim.subpopulations) { 
		inds = subpop.individuals;
		if (size(inds)==0) {
			catn("empty subpop "+subpop.id);
			deadpops=deadpops+1;
			next;
		}
		adults=which(inds.age>4);
		subpop.setValue("adultCount",size(adults));
		if (size(adults)<1) { 
			deadpops=deadpops+1;
			catn("no adults in subpop "+subpop.id);
		}
		phenotypes = inds.sumOfMutationsOfType(m2)+ inds.tagF;
		//catn(phenotypes);
		subpop.setValue("phenotypes",phenotypes);
		// #now we define a fitness function according to the env at each generation and taking into account the QTL and plasticity 
		// #gaussian fitness function following the shape of N(0,1)
		phenoFitness=(fitcushion + dnorm(subpop.getValue("env")[sim.generation]- phenotypes, 0,pl)) / (maxfit + fitcushion);
		//catn(mean(phenoFitness));
		subpop.setValue("phenoFitness",phenoFitness);
		//density dependance below:
		ages = inds.age;
		mortality = L[ages];
		survival = 1 - mortality;
		//total fitness:
		inds.fitnessScaling = survival*phenoFitness;
//		catn(inds.fitnessScaling[adults]);
		subpop.fitnessScaling = subpop.getValue("popsize")/ (subpop.individualCount * mean(inds.fitnessScaling));
		if (subpop.fitnessScaling>1 & sim.generation>2100) {
			subpop.fitnessScaling=1;
		}
	}
	//stop if all pop are deads:
//	catn("deadpops: "+deadpops);
	if (deadpops==size(sim.subpopulations)) { sim.simulationFinished(); }
}

// increasing pop size / decreasing mutation rate (initial genetic equilibration)
// requalibration
// 
2000 late() {
	for (p in seqLen(npops)){
		sim.subpopulations[p].setValue("popsize",asInteger(10+popscale*asInteger(popsizes[p])/10));
	}
   sim.chromosome.setMutationRate(1e-05*10);
}

// back to normal !
4000 late() {
	for (p in seqLen(npops)){
		sim.subpopulations[p].setValue("popsize",asInteger(10+popscale*asInteger(popsizes[p])));
	}
   sim.chromosome.setMutationRate(1e-05);
}

// output, for adults in each pop: 
// - mean fitness
// - mean phenotype
// - environmental setting in the current generation
// - number of segregating m2 mutations
// - genetic varation (sd of breeding value)
// - mean age 
// - number of adults
// - fraction of adults that died that year
4500: late() {
	bvalues=sim.subpopulations.individuals.sumOfMutationsOfType(m2);
	if (size(bvalues)==0) { 
		catn("no bvalues: "+size(bvalues));
		sim.simulationFinished(); 
	}
	cat("#TotalG\t"+sim.generation+"\t"+size(sim.mutationsOfType(m2))+"\t"+sd(bvalues)+"\n");
	for (p in seqLen(npops)){
		pop=sim.subpopulations[p];
		mf=sim.mutationFrequencies(pop,sim.mutationsOfType(m2));
		nmuts=sum(mf>0 & mf<1);
		adults=which(pop.individuals.age>2);
//		catn(pop.cachedFitness(adults[1:5]));
		if (size(adults)>1){
			cat(sim.generation +"\t"  + p +"\t"+mean(pop.getValue("phenoFitness")[adults])+ "\t" + mean(pop.getValue("phenotypes")[adults])+"\t"+ pop.getValue("env")[sim.generation] + "\t"+nmuts+"\t"+sd(pop.individuals[adults].sumOfMutationsOfType(m2))+"\t"+mean(pop.individuals[adults].age)+"\t"+size(adults)+"\t"+(pop.getValue("adultCount") - size(adults))/pop.getValue("adultCount")+"\n");
		} 
		else { 
			cat(sim.generation +"\t" + p +"\tNA\tNA\t"+ pop.getValue("env")[sim.generation] + "\tNA\tNA\tNA\t"+size(adults)+"\t"+(pop.getValue("adultCount") - size(adults))/pop.getValue("adultCount")+"\n");
		}
	}
}
// back to normal !
5400 late() {
	for (p in 0:21){
		sim.subpopulations[p].setValue("popsize",asInteger(10+popscale*asInteger(popsizes[p])/500));
	}
}
//print data at different time scales around warming:
// output all mutations post-burnin and after 50 and 100 generations of warming
5499 late() { 
		sim.outputMutations(sim.mutationsOfType(m2));
}



// output all mutations post-burnin
5550 late() { 
		sim.outputMutations(sim.mutationsOfType(m2));
}
// output all mutations post-burnin
5600 late() { 
		sim.outputMutations(sim.mutationsOfType(m2));
}
// output all mutations post-burnin
5650 late() { 
		sim.outputMutations(sim.mutationsOfType(m2));
}


5994 late() {}

