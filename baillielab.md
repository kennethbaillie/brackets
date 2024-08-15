# Baillielab shared task list

<!--
How to use this file. 
This is a shared tasklist to serve as a reminder to everyone, to make sure key tasks don't get forgotten. 
It is not secure so don't put anything confidential here. 
Try to be specific about each task, and include tasks that are to be completed in the timescale of weeks or months.
-->

# Lab business

- [X] Job description for new sys admin role to aggregate gVCF genome sequence files. [Wilna]


## Grants

- Apply to FEAT +/- Wellcome for international GenOMICC grant [Kenny]


Q2 24
- [ ] ISP - DEADLINE 10/05/24:  Artificial Insemination or IVF using cryopreserved porcine sperm. [Sara]
- [ ] CMVM Research Impact Fund 13/05/24: GenOMICC - Patient and Public Involvement (PPI) for new preterm birth cohort. [Sara, Fiona]

### Awaiting outcome
Q1 24
- [X] Action for Children: pre-application (External) DEADLINE 27/02/24 : The genetic basis of bronchopulmonary dysplasia in the UK population [Sara]
- [X] INSPIRE - DEADLINE 22/04/24: MAIC BPD [Chris H]
- [X] ECR ISP - DEADLINE 05/05/24 : Delivery of Cas9 protein by non-integrating lentiviruses. [Akira]

## Team management

- draft new guidance on ways of working here: https://www.dropbox.com/scl/fi/irojla4ub1fpp9qhy6dmv/ways_of_working.md?rlkey=f7hqxfvgxpjzsmoxpp6afy21c&dl=0 [Wilna, Kenny]
- draft summary of future team member roles and descriptions [Wilna]
- provide cost projection against all grants [Wilna]

## Projectviewer

- [ ] tease out mechanics of Jim's projectviewer system and work out how to maintain it [Kenny, ?Andy]
- [ ] make live reload work again for use in meetings - maybe revert to Kenny's original code

# Alphafold WGS analysis

## make choice between db architectures [Dominique, Konrad]
- zetta genomics: xetabase
- GenomicsDB (Kenny's favourite...)

## Phase 1: pilot
- add atp11a to list [Konrad] IFNAR(1/2?) (SLC22A31, SFTPD) (TLR7, SLC50A1)
- [X] Set up protein model in EIDF [Jonny]
- write cram to amino acid sequence code, write association test [Konrad]
- choose priority order for models (add models iteratively in order + add splicing in future) [Konrad] 

## Phase 2: scaling
- engage with EPCC to scale onto CS2 [Kenny, Konrad]
- arrange review meeting after pilot [Konrad]

# GenOMICC management

## UK

- [x] block out time for roadshow [Kenny]

## International

- draft Horizon ERC proposal summary one pager [Miranda]
- get Symen into ODAP [Miranda]
- [ ] data from Canada/Belgium: create and share internal data sharing system and add to ODAP documentation [Miranda]
- FEAT proposal - generate numbers and share with Kenny and Wilna [Miranda]

# ODAP

- [x] Implement cost recovery model with mechanism via EI [Wilna]
- [ ] Check that ODAP SOP guidance makes this risk clear: If SDF file system permissions are not set correctly, data could be exposed to any superdomeflex user [Dominique]

# Functional genomics EMMC including PIG and MOUSE data

- [ ] create new planning directory for EMMC [Kenny]
- [X] find altitude samples <2015 [Sara]
- [ ] find altitude samples >2015 [Kenny]
- [ ] create draft schedule for 2 postdocs in EMMC [Sara]
- [ ] Plan kick-off meeting [Kenny]

- [ ] decide on GWAS genes from https://www.ebi.ac.uk/gwas/: looking at genes with most hits and compare with eQTL databases to see whether gene variants have been associated with eQTLs   [Valentina]

# ISARIC4C

- redraft CCP global [Kenny]
- redraft CCP UK [Kenny, Wilna, Miranda, Primmy]
- find out how much freezer capacity needed for plasma samples ? from shona moore [sara]
- buy freezers [Sara, Wilna]
- get plasma samples from Liverpool and Glasgow [Wilna, Sara]
- arrange hepatitis meeting [Wilna/Jen]

# GenOMICC/ISARIC4C analyses

## Infrastructure

- draft governance and prev spec summary and send to Kenny [Wilna]
- set up new FCS and move data to new structure [Andrew Brooks, Scott]
- incorporate data handling guidance for genetic data into existing ODAP documentation [Miranda, Dominique, Wilna]
- transfer ISARIC4C case report form data for GenOMICC patients from Safe Haven into FCS [Nikos, Donimique, Wilna]

## GWAS

- [ ] Get the GWAS pipeline going that Konrad and Erola have been working on [Valentina]
- [ ] Mortality GWAS [Valentina]
- [ ] influenza GWAS [Valentina]
(sepsis GWASes and hyprcoloc with covid?)

## Post GWAS analyses
- [ ] HyPrColoc for influenza GWAS with Covid and relate diseases [Marie]
- [ ] influenza GSMR [Jian/Andy]

## Comparison of methodologies

- compare cytokines, proteomics, RNAseq for detection of stratification signals [Dominique]

## inducibible eQTL

- [x] detect eQTL in RNAseq data [Valentina]
- [ ] confirm and interpret RNA eQTL data [Valentina]
- detect eQTL in protein [Valentina]

## host:virus analysis
- [ ] prepare data explainer for host:virus analysis [Dominique]
- [ ] call new kick-off meeting [Kenny]

## Replication Japan GWAS
- [ ]  Look whether the JAPAN GWAS hits replicate in GenOMICC [Ana]

## Hepatitis

- [ ] pull together hepatitis data. [Andy Law?]
- [ ] run GWAS of hepatitis cases [Simone Weyand]

## Group A Strep

- [ ] Collate and genotype GenOMICC [Miranda]
- [ ] Draft *internal* project plan for Gp A strep [Miranda]

## Methods evaluation

- [ ] Clusters in GenOMICC & test association [Nikos]
- [ ] probability function method to test for independent mechanism in GWAS [Konrad]
- [ ] Determine whether stratification signals revealed by cytokine analysis are also detectable in RNAseq data [Dominique]
- [ ] Find e/pQTL unmasked by disease in isaric4c/genomicc data [Dominique]
- [ ] Determine whether CAGE is better than RNAseq [Dominique]

# MAIC

- [ ] test input characteristics (noise, heterogeneity etc) of biological datasets and evaluate optimal method for aggregation
- [ ] collate pipeline for running a MAIC analysis from the beginning to end [?Dominique/Ratika]

## MAIC analyses

- Yeast and other species - impact on viral replication MAIC analyses [Charlotte Scoynes]
- Covid & ARDS [Chris Happs]
- ARDS animal models [Johnny]
- neuro [Moritz, Zoeb]
- Bronchopulmonary dysplasia - human [Sara, Prerna]
- Bronchopulmonary dysplasia - animal [Sara, Chris]
- [ ] MAIC for SHIELD [Marie]

# Prioritising drug targets

- [ ] make quarto index file for genomicc-genes repo[Ana]
- [ ] work out how to display git repo as website securely [Ana]
- [ ] evaluate harmonic sum method / MAIC for prioritisation [Dominique]
– [ ] explore genetically supported influenza drug targets ahead of Drug Target Prioritisation group meeting [Marie]

# Human disease atlas

- [ ] pilot disease-disease pairings with Covid [Marie]

# Wetlab

## Localised genome editing in the porcine lung – a model for target validation in pulmonary critical illness [Akira, Nelly, Sara, Johnny, TUM]

- [ ] Meeting with TUM [May]
	- [X] Formal invite [Sara, Jen]
	- [X] Seminar booked [Sara]
 	- [X] Larif Emailed [Jen]
        - [X] Larif Booked [Jen]
  	- [X] Legal notified [Sara]
  	- [X] MTA draft information 
  	- [X] Dinner booked [Sara]
  	- [ ] catering booked [Jen]
  	- [X] accommodation booked [Jen]
  	- [ ] travel booked [Jen] - passport problem
     
  	      
- [ ] Meeting with Mahsoud [June]
	- [ ] Sit down meeting with Kenny to organise an experiment [Sara]
	- [ ] Pig book [Sara]

Lower priority:
- Expand genes being examined [Nelly, Akira, Sara]
- Compare genes from COVID paper vs number for sgRNAs for potential next targets [Sara]

## Optimisation of viral vectors for ex vivo genome editing in porcine lung tissue [Akira]

Chosen targets: CAV2, GGTA1

### Transduce Cas9 PCLS and optimise cutting efficiency

- confirm transduction efficiency for lenti (GGTA1/CAV2) in lung slice (using mCherry or sequencing for CAV2/GGTA1 edits) [Akira, Nelly]

#### Optimise sgRNA and comparisons [Nelly, Akira]

- [ ] Directly compare sgRNA using PKLV2 transfection [Nelly]
	Important for method development per sgRNA
	Performed once - requires repeat
	Need to check exon 6 levels from rtPCR as higher in sgRNA6 transduced.

- [ ] Identify membrane marker for pig epithelium [Nelly]
	- [ ] membrane tracker (https://biotium.com/product/cellbrite-fix-membrane-stains/)	

#### Confirm detection of CAV2 in PCLS (high priority)

X [ ] IF with NSK-Cas9 transfected with hPKLV2-sgCAV2 PLASMID and stained with CAV2 antibody [Nelly]
- Maybe less important now?
  
- [X] IF with NSK-Cas9 transduced with hPKLV2-sgCAV2 LENTI and stained with CAV2 antibody [Nelly]
	Nice staining. propose staining with membrane protein and anti-mCherry.

X [ ] Immunoblot with NSK-Cas9 transfected with hPKLV2-sgCAV2 PLASMID and stained with CAV2 antibody [Nelly, Akira]
- Maybe less important now?
  
- [ ] Immunoblot with NSK-Cas9 transduced with hPKLV2-sgCAV2 LENTI and stained with CAV2 antibody [Nelly, Akira]
      
- [X] Design qPCR  primers CAV2 [Nelly]
	<!-- Done -->
- [X] Test qPCR  primers CAV2 [Nelly]
	<!-- Done -->
- [ ] Confirm CAV2 knockdown [Nelly]
   - KD with sgRNA3 
  
#### Confirm detection of GGTA1 in PCLS (high priority)
<!-- exons are strange -->
- [ ] Continuing the detection (RT-PCR) to confirm if annotated exons are expressed [Akira]

#### Lenti virus vector optimisation

- [ ] Grow lenti [Akira]
	- [X]  Sendai
 	<!-- Made! -->
		- Transduce pigs cells [Akira]
    		<!-- Done -->
  		- Transduce pig lung cells [Akira]
   	- [X]  Flu pseudotyped
  	<!-- Made! -->
     		- Transduce pig cells [Akira]
  		<!-- Done -->
       		- Transduce pig lung cells [Akira]
      		<!-- Done -->
      	
- [ ]  Transduce WT PCLS [Akira]
	- [ ] Sendai
 	- [X] Flu pseudotyped
   	<!-- Done -->

- [ ]  Detection of LV in WT PCLS [Akira]
	- [ ] HCR detection of GFP/WPRE/Scaffold [Akira]
 		- [ ] AB of slices GFP [Akira]
   		- [ ] HCR probe for GFP/WPRE [Akira]
	- [ ] Visualise Lv integration / PCR  [Akira]


- [ ]  Sequence A/Swine/Eng/453/06 [Akira]
	still to do polymerases.
BONUS: Mutate segment 8 of pDual swine h1n1 to remove polyA export blocking.

#### Conditioning

 - [X] LPC [Nelly]
	 - [ ] Determine the concentration of LPC to use
	 	- [ ] 1% versus 0.1% PCLS with MOI10^7  VSVG with GFP/mCherry up to 72 hours (19/04)
	 - [ ] Determine the optimum period of time to condition PCLS
	 - [ ] Determine the cells transduced with VSV-G and HA
  - [ ] Sodium caprate/deconoate [Nelly]
	 - [ ] Determine the concentration of SC to use
	 - [ ] Determine the optimum period of time to condition PCLS
	 - [ ] Determine the cells transduced with VSV-G and HA
======================================================================================================================
## Investigating the response of genome-edited porcine precision-cut lung slices to pathogenic stimuli [Nelly]

### Compare influenza A virus infection in PCLS using different strains [Nelly]

<!-- 
On backburner until new pig 

- [ ]  Optimise microscopy in PCLS [Nelly]
- [ ]  Optimise detection of IAV in PCLS by confocal microscopy [Nelly]
- [ ]  A549 co-culture in PCLS [Nelly]
- [ ]  NSK co-culture in PCLS [Nelly]

-->

======================================================================================================================
## Single-cell transcriptional profiling of porcine lung during severe viral infection [Akira, Nelly, Josh, Sara]

### Analysis [Sara]

- [X] BLAST against bacterial/viral pathogen diagnostics [Eamonn]
- [X] QC and data processing [Eamonn]
- [X] Recluster Sample 1 and Sample 4 based on EPCAM expression [Sara]
- [X] Orthologs (JEM script) [Sara]
- [X] Model lung cells - Cell Typist [Sara]
- [ ] Define cell types in pig lung [Eamonn, Sara]

- Human vs pig [Sara]

- [ ]  Flu vs control [Eamonn, Sara]
- [ ]  what cells have flu in them? When (segment 7 versions)? Replicating i.e. mRNAs? [Eamonn, Sara]
- [ ]  Ratio of early to late genes [Sara]

- Splice variants in flu (BONUS) [Eamon, Sara]
  
- [ ]  compare expression of immune genes [Eamonn, Sara]

======================================================================================================================
## Investigation of the saccular stage of lung development in mammals by scRNAseq [Sara]

### Sheep fetus
======================================================================================================================
## The role of ATP11A in enveloped RNA virus infection of mammalian lung [Josh]

- Josh's [aims and objectives](https://github.com/jrogers3UE/Meeting-Notes)

======================================================================================================================


# Website

- [X] Obtain/update bios and photos for Nelly, Akira [Sara]
- [ ] Obtain/update bios and photos for Giovanna,Nneka [Konrad]
- [ ] Obtain/update bios and photos for Max, Emma [Kenny]
- [ ] Give write access to lab website to Sara, Wilna, Dominique [Kenny]

# Undergraduate students

- Anya Tan, altitude eQTL
- Chris Happs, BMedSci student, starting in January


======================================================================================================================

# Communications and Design

- [ ] PPI Leaflets (for 7 different target groups) [Marie, Fiona]
– [ ] PPI Info sheets for follow up [Marie, Fiona]
– [ ] Consent Form overhaul [Marie, Fiona]
- [ ] Dataflow diagram [Marie, Fiona]
- [ ] GenOMICC presence at conferences [Marie]
– [ ] Poster re-design [Marie]
– [ ] Baillie lab colour suite [Marie]

