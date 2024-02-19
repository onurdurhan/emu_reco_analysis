#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Script for performing the two required linking steps. Usage is: '
    echo ' '
    echo 'just replace nfrom_plate and nto_plate with corresponding numbers'
    return 0
fi
fromplate=$1
toplate=$2
CELL=$3

echo "Set up SND environment"
source /cvmfs/sndlhc.cern.ch/SNDLHC-2023/Aug30/setUp.sh
source /afs/cern.ch/user/o/onur/SNDLHCSOFT_BASE/config.sh
source /afs/cern.ch/user/o/onur/fedra/setup_new.sh
echo "do linking for cell "$CELL
echo "from plate " $fromplate
echo "to plate " $toplate
AFSHOME=/afs/cern.ch/user/o/onur
EOSPATH=$EOSSHIP/eos/experiment/sndlhc/emulsionData/2022/CERN/emu_reco/RUN3
BRICKID=51
BRICKFOLDER="$(printf "b%0*d" 6 $BRICKID)"
RECODATAPATH=$EOSPATH/$BRICKFOLDER
RAWDATAPATH=/eos/experiment/sndlhc/emulsionData/2022/CERN/SND_mic2/RUN3/RUN3_W5_B1
mkdir $BRICKFOLDER
echo $(pwd) "is the currrent path"
CURRENT_DIR=$(pwd)
cd $CURRENT_DIR/$BRICKFOLDER
xrdcp $AFSHOME/emulsion_tasks/reco_scripts/linking/firstlink.rootrc $CURRENT_DIR/$BRICKFOLDER/link.rootrc

#finally doing cell by cell linking
var1=$3
xbin=$((var1 / 18))
ybin=$((var1 % 18))

#starting from 1 to 18, not 0 to 17
xname=$((xbin + 1))
yname=$((ybin + 1))

for iplate in $(seq $2 $1)
  do
  RAWPLATEFOLDER="$(printf "P%03d" $(( 10#$iplate )))"
  PLATEFOLDER="$(printf "p%03d" $(( 10#$iplate )))"
  mkdir $PLATEFOLDER
  ln -s $RAWDATAPATH/$RAWPLATEFOLDER/tracks.raw.root $PLATEFOLDER/$BRICKID.$iplate.$xname.$yname.raw.root
  echo created link $PLATEFOLDER to folder $RAWDATAPATH/$RAWPLATEFOLDER
  echo "The current directory" $(pwd)
  echo "the content of the directory" $(ls -lha $PLATEFOLDER)
  echo "$PLATEFOLDER/$BRICKID.$iplate.$xname.$yname.raw.root"
done

makescanset -set=$BRICKID.0.$xname.$yname  -dzbase=175 -from_plate=$1 -to_plate=$2 -v=2 -reset

echo "Starting pre-linking"

makescanset -set=$BRICKID.0.$xname.$yname -dzbase=175 -from_plate=$1 -to_plate=$2 -v=2


emlink -set=$BRICKID.0.$xname.$yname -new -v=2 -ix=$xbin -iy=$ybin

xrdcp b0000$BRICKID.0.$xname.$yname.link.ps $RECODATAPATH/plot_prelink/b0000$BRICKID.0.$xname.$yname.prelink_$1_$2.ps

for iplate in $(seq $2 $1)
 do
  platefolder="$(printf "p%0*d" 3 $iplate)"
  xrdcp $platefolder/$BRICKID.$iplate.$xname.$yname.cp.root $RECODATAPATH/$platefolder/$BRICKID.$iplate.$xname.$yname.firstlinkcp.root
 done

 
echo "Starting true linking"
rm $CURRENT_DIR/$BRICKFOLDER/link.rootrc
xrdcp $AFSHOME/emulsion_tasks/reco_scripts/linking/secondlink.rootrc $CURRENT_DIR/$BRICKFOLDER/link.rootrc

makescanset -set=$BRICKID.0.$xname.$yname -dzbase=175 -from_plate=$1 -to_plate=$2 -v=2

emlink -set=$BRICKID.0.$xname.$yname -new -v=2 -ix=$xbin -iy=$ybin

for iplate in $(seq $2 $1)
 do
  platefolder="$(printf "p%0*d" 3 $iplate)"
  xrdcp $platefolder/$BRICKID.$iplate.$xname.$yname.cp.root $RECODATAPATH/$platefolder
  xrdcp $platefolder/$BRICKID.$iplate.$xname.$yname.par $RECODATAPATH/$platefolder
 done
xrdcp b0000$BRICKID.0.$xname.$yname.link.ps $RECODATAPATH/plot_link/b0000$BRICKID.0.$xname.$yname.link_$1_$2.ps
xrdcp AFF/* $RECODATAPATH/AFF
