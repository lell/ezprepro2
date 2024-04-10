#!/usr/bin/env bash
source code/global.sh

# Create kinship matrix (step 2/2)

mkdir -p scripts/H10
mkdir -p logs/H10
mkdir -p runtimes/H10 

sed -i -E "s/-9$/1/" genetics/filter3/merged-.fam

file="scripts/H10/r2"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J H10r2" >> $file
echo "#SBATCH -o $(pwd)/logs/H10/run2.o -e $(pwd)/logs/H10/run2.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd genetics/filter3;" >> $file
echo "../../bin/gemma-v0.98 -bfile merged- -gk 2 -o kinship.2" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/H10/run2" >> $file
chmod +x scripts/H10/r2
sbatch scripts/H10/r2

file="scripts/H10/r3"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J H10r3" >> $file
echo "#SBATCH -o $(pwd)/logs/H10/run3.o -e $(pwd)/logs/H10/run3.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd genetics/filter3;" >> $file
echo "../../bin/gemma-v0.98 -bfile merged- -gk 1 -o kinship.1" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/H10/run3" >> $file
chmod +x scripts/H10/r3
sbatch scripts/H10/r3

sleep 10m;

while [ $(squeue -u $(whoami) | grep H10 | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "H10 done"
