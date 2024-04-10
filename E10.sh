#!/usr/bin/env bash
source code/global.sh

# Remove multi-allelic SNPs (step 2/3)

mkdir -p scripts/E10
mkdir -p logs/E10
mkdir -p runtimes/E10
if [ ! -f $(pwd)/genetics/filter3/merged.bed ]; then
file="scripts/E10/run"

echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J E10" >> $file
echo "#SBATCH -o $(pwd)/logs/E10/run.o -e $(pwd)/logs/E10/run.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd genetics/filter3;" >> $file
echo "../../bin/plink1.9 --bfile chr01 --merge-list ../../data/merge-list.txt --make-bed --out merged --memory $MAXMEM;" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/E10/run" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file

fi
sleep 10m;

while [ $(squeue -u $(whoami) | grep E10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "E10 done"
