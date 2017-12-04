Run Replica Exchange Umbrella Sampling (REUS) on GPUs with AMBER.

Begin by putting your prmtop file in the main directory and a rst file for each window in start_files. Then edit the 'metropolis.cfg' file and 'restraint_file.rst' to match the correct file names, distances, and atom numbers for your system. Edit the 'reus.in' file to change the length of each simulation between exchange attempts.

Ensure that the .py scripts point to a working python 2.7 executable and that MDAnalysis is installed. Running 'print_MDAnalysis_version.py' will test if this things are setup correctly.

Now run the setup script to setup the directory for running REUS. This should create several win.# directories with each containing their own starting file, restraint file, and 'reus.in' file.

Finally, edit the top portion of 'wrapper.sh'. 'runs' is the number of REUS exchange steps throughout the simulation. 'start_run' is the starting run number, it should be 0 for the first REUS run, it can be changed if the REUS run is interupted at any time so that you dont overwrite previously generated files. 'ngpu' is the number of GPUs to use in parallel. 'windows' is the total number of windows. 'MFP' is the residue name of the solutes of interest, this should match the prmtop file name. 'exchange_out' is the output file that will contain a record of the attempted exchanges. You don't have to edit the cpptraj_combine. Finally, 'cpptraj_freq' is the number of runs this script will combine into one larger file so that you don't end up with directories filled with thousands of files.
