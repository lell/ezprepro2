#!/usr/bin/env bash
source code/global.sh

# Create kinship matrix (step 1/2)

mkdir -p scripts/G10
mkdir -p logs/G10
mkdir -p runtimes/G10
if [ ! -f $(pwd)/genetics/filter3/merged-.bed ]; then
file="scripts/G10/r1"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J G10r1" >> $file
echo "#SBATCH -o $(pwd)/logs/G10/run.o -e $(pwd)/logs/G10/run.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd genetics/filter3;" >> $file
echo "../../bin/plink1.9 --bfile chr01- --merge-list ../../data/merge-list-.txt --make-bed --out merged- --memory $MAXMEM;" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/G10/run" >> $file
chmod +x scripts/G10/r1
sbatch scripts/G10/r1
fi
sleep 10m;

while [ $(squeue -u $(whoami) | grep G10 | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "G10 done"
