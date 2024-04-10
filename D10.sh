#!/usr/bin/env bash
source code/global.sh

# Remove multi-allelic SNPs for kinship matrix computation (step 1/3)

mkdir -p genetics
mkdir -p genetics/filter3
mkdir -p scripts/D10
mkdir -p logs/D10
mkdir -p runtimes/D10

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/filter3/chr${i2}.bed ]; then
    token="D10${i2}"
    file="scripts/D10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/D10/$token.o -e $(pwd)/logs/D10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd genetics/filter3;" >> $file
echo "../../bin/plink1.9 --bgen chr${i2}.bgen --sample chr${i2}.sample --make-bed --out chr${i2} --memory $MAXMEM;" >> $file
echo "T2=\$(date \"+%s\")" >> $file
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/D10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done
sleep 10m;

while [ $(squeue -u $(whoami) | grep D10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "D10 done"
