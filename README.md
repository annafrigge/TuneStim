# DBS TuneStim (TuneS)
TuneS is a pipeline intended to enable model-based parameter selection for deep brain stimulation. 
TuneS simulates the inducedelectric field using a detailed finite-element model. By using pre- and post-
operative neuroimages, the model is customized to the patient-specific brain
anatomy. The simulated electric field is scaled according to a constrained op-
timization scheme to maximally stimulate target areas while structures asso-
ciated with adverse side-effects are avoided. The volume of tissue activated is
computed using an activation threshold on the electric field strength.



## Dependencies
Lead-DBS (v. 2.6 ),
COMSOL Multiphysics (v. 6, 5.5),
MATLAB (v. 2020b)

## Repository Structure
The core for TuneS, is the TuneStim folder holding the functions and files. In the Comsol-folder, COMSOL-models and model-related files are stored. In the MNI-folder, segmented NIfTI-files represeting the white- and grey matter, and the cerebrospinal fluid are stored. 
In the folder sBatchOutput, the slurm job log files are stored in case the pipeline is run as a slurm job on a cluster.

## Preprocessing with Lead-DBS
Before using TuneS, the pre- and postoperative acqusitions need to be pre-processed. This includes co-registration of pre- and postoperative images, normalization to MNI space and reconstruction of the lead coordinates using Lead-DBS. 

## Getting started.
Open the GUI by double-clicking the file 'TuneS.mlapp'. Insert your input parameters of choice and run.
Check the following pre-print for additional information:

