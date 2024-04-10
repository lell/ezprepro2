#!/usr/bin/env bash
source code/global.sh

# Subset to disco/repro sets

mkdir -p scripts/J10
mkdir -p logs/J10
mkdir -p runtimes/J10 
mkdir -p genetics/disco1 
mkdir -p genetics/repro1 

N=$(cat data/ids2.txt | wc -l);
N1=$(bc <<< "scale=0; $N * 2.0 / 3.0");
N2=$(bc <<< "scale=0; $N1 + 1");

RANDOM=42
get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

shuf --random-source=<(get_seeded_random 42) \
  < data/ids2.txt | head -n $N1 > data/disco.txt

shuf --random-source=<(get_seeded_random 42) \
  < data/ids2.txt | tail -n +$N2 > data/repro.txt

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/disco1/chr${i2}.bgen ]; then
token="J10d${i2}"
file="scripts/J10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/J10/$token.o -e $(pwd)/logs/J10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g genetics/filter1/chr${i2}.bgen -s genetics/filter1/chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/disco1/chr${i2}.bgen -os $(pwd)/genetics/disco1/chr${i2}.sample -incl-samples $(pwd)/data/disco.txt; cd genetics/disco1; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/J10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done

while [ $(squeue -u $(whoami) | grep J10d | wc -l) -gt 0 ]; do
  sleep 1h;
done

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/repro1/chr${i2}.bgen ]; then
token="J10r${i2}"
file="scripts/J10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/J10/$token.o -e $(pwd)/logs/J10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g genetics/filter1/chr${i2}.bgen -s genetics/filter1/chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/repro1/chr${i2}.bgen -os $(pwd)/genetics/repro1/chr${i2}.sample -incl-samples $(pwd)/data/repro.txt; cd genetics/repro1; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/J10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep J10r | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "J10 done"
