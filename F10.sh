#!/usr/bin/env bash
source code/global.sh

# Remove multi-allelic SNPs (step 3/3)

mkdir -p genetics
mkdir -p genetics/filter3
mkdir -p scripts/F10
mkdir -p logs/F10
mkdir -p runtimes/F10

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/filter3/chr${i2}-.bed ]; then
token="F10${i2}"
file="scripts/F10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/F10/$token.o -e $(pwd)/logs/F10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g $(pwd)/genetics/filter3/chr${i2}.bgen -s $(pwd)/genetics/filter3/chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/filter3/chr${i2}-.bgen -os $(pwd)/genetics/filter3/chr${i2}-.sample -excl-rsids $(pwd)/genetics/filter3/merged-merge.missnp"  >> $file
echo "cd $(pwd)/genetics/filter3" >> $file
echo "../../bin/plink1.9 --bgen chr${i2}-.bgen --sample chr${i2}-.sample --make-bed --out chr${i2}- --memory $MAXMEM;" >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/F10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
    sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep F10 | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "F10 done"
