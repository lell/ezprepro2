#!/usr/bin/env bash
source code/global.sh

# Find maximal set of unrelated subjects

mkdir -p scripts/I10
mkdir -p logs/I10
mkdir -p runtimes/I10 

file="scripts/I10/r2"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J I10r2" >> $file
echo "#SBATCH -o $(pwd)/logs/I10/run2.o -e $(pwd)/logs/I10/run2.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd);" >> $file
echo "module load R" >> $file
echo "code/relate" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "echo \$(expr \$T2 - \$T1) > runtimes/I10/run2" >> $file
chmod +x scripts/I10/r2
sbatch scripts/I10/r2

sleep 10m;

while [ $(squeue -u $(whoami) | grep I10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "I10 done"
