#!/bin/bash
echo "Set up SND environment"
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
source /afs/cern.ch/user/o/onur/SNDLHCSOFT_BASE/config.sh
source /afs/cern.ch/user/o/onur/fedra/setup_new.sh	
echo  "merge cells for plate", $PLATENUMBER
PLATENUMBER=$3
EOSPATH=/eos/experiment/sndlhc/emulsionData/2022/CERN/emu_reco/RUN3/
#EOSPATH=/eos/user/o/onur/playground
BRICKID=51
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
AFSHOME=/afs/cern.ch/user/o/onur
PLATEFOLDER="$(printf "p%03d" $((10#$PLATENUMBER)))"
root -l -q "$AFSHOME/emulsion_tasks2/reco_scripts/linking/merge_couplestrees.C(\"$EOSPATH\",$BRICKID,$PLATENUMBER)"
xrdcp *.root $EOSSHIP/$EOSPATH/$BRICKFOLDER/$PLATEFOLDER
