#!/bin/bash
FROMPLATE=$1
TOPLATE=$2
echo "Set up SND environment"
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
source /afs/cern.ch/user/o/onur/SNDLHCSOFT_BASE/config.sh
source /afs/cern.ch/user/o/onur/fedra/setup_new.sh

AFSHOME=/afs/cern.ch/user/o/onur
EOSPATH=/eos/experiment/sndlhc/emulsionData/2022/CERN/emu_reco/RUN3/
BRICKID=51
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
RECODATAPATH=$EOSSHIP/$EOSPATH/$BRICKFOLDER
RAWDATAPATH=/eos/experiment/sndlhc/emulsionData/2022/CERN/SND_mic2/RUN3/RUN3_W5_B1

mkdir $BRICKFOLDER
CURRENT_DIR=$(pwd)
cd $CURRENT_DIR/$BRICKFOLDER


for iplate in $(seq $2 $1)
  do
  RAWPLATEFOLDER="$(printf "P%03d" $(( 10#$iplate )))"
  PLATEFOLDER="$(printf "p%03d" $(( 10#$iplate )))"
  mkdir $PLATEFOLDER
  xrdcp $RECODATAPATH/$PLATEFOLDER/$BRICKID.$iplate.0.0_merged.cp.root $PLATEFOLDER/$BRICKID.$iplate.0.0.cp.root
  ln -s $RAWDATAPATH/$RAWPLATEFOLDER/tracks.raw.root $PLATEFOLDER/$BRICKID.$iplate.0.0.raw.root 
done

echo "do alignment"

xrdcp $AFSHOME/emulsion_tasks/reco_scripts/alignment/first_align.rootrc $CURRENT_DIR/$BRICKFOLDER/align.rootrc

makescanset -set=$BRICKID.0.0.0 -dzbase=175 -dz=-1350 -from_plate=$1 -to_plate=$2 -v=2 -reset

echo "Starting first align"

emalign -set=$BRICKID.0.0.0 -new -v=2

xrdcp b0000$BRICKID.0.0.0.align.ps $RECODATAPATH/plot_first_align/b0000$BRICKID.0.0.0.firstalign_$1_$2.ps
rm $CURRENT_DIR/$BRICKFOLDER/align.rootrc
xrdcp $AFSHOME/emulsion_tasks/reco_scripts/alignment/second_align.rootrc $CURRENT_DIR/$BRICKFOLDER/align.rootrc

makescanset -set=$BRICKID.0.0.0 -dzbase=175 -from_plate=$1 -to_plate=$2 -v=2 

echo "Starting second align"

emalign -set=$BRICKID.0.0.0 -new -v=2

xrdcp b0000$BRICKID.0.0.0.align.ps $RECODATAPATH/plot_second_align/b0000$BRICKID.0.0.0.secondalign_$1_$2.ps
rm $CURRENT_DIR/$BRICKFOLDER/align.rootrc
xrdcp $AFSHOME/emulsion_tasks/reco_scripts/alignment/local_align.rootrc $CURRENT_DIR/$BRICKFOLDER/align.rootrc

makescanset -set=$BRICKID.0.0.0 -dzbase=175 -from_plate=$1 -to_plate=$2 -v=2 

echo "Starting test align with very precise parameters"

emalign -set=$BRICKID.0.0.0 -new -v=2

xrdcp b0000$BRICKID.0.0.0.align.ps $RECODATAPATH/plot_local_align/b0000$BRICKID.0.0.0.localalign_$1_$2.ps

for iplate in $(seq $2 $1)
  do
  PLATEFOLDER="$(printf "p%03d" $(( 10#$iplate )))"
  xrdcp $PLATEFOLDER/$BRICKID.$iplate*par /$RECODATAPATH/$PLATEFOLDER/
done
xrdcp AFF/* $RECODATAPATH/AFF
xrdcp *.set.root $RECODATAPATH/$BRICKID.finealign_$1_$2.set.root
echo "Tasks Finished"
