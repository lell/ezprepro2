# ezprepro

The **ezprepro** pipeline provides the preprocessing described in [S.M. Smith et al. 2021. *An expanded set of genome-wide association studies of brain imaging phenotypes in UK Biobank*](https://www.nature.com/articles/s41593-021-00826-4) for brain imaging genetics on UK Biobank. This pipeline has been used for the following work:

- [J. Manuello et al. 2024. *The effects of genetic and modifiable risk factors on brain regions vulnerable to ageing and disease*](https://open.win.ox.ac.uk/pages/douaud/ukb-lifo-flica/)

- [S. Lee et al. 2022. *Amplitudes of resting-state functional networks&mdash;investigation into their correlates and biophysical properties*](https://www.sciencedirect.com/science/article/pii/S1053811922009004)

- [C. Wang et al. 2022. *Phenotypic and genetic associations of quantitative magnetic susceptibility in UK Biobank brain imaging*](https://www.nature.com/articles/s41593-022-01074-w)

- [S.M. Smith et al. 2021. *Brain aging comprises many modes of structural and functional change with distinct genetic and biophysical associations*](https://elifesciences.org/articles/52677)

- [J. Mollink et al. 2019. *The spatial correspondence and genetic influence of interhemispheric connectivity with white matter microstructure*](https://www.nature.com/articles/s41593-019-0379-2)

The scripts for the **ezprepro** pipeline are provided [here](https://github.com/lell/ezwin/tree/master/ezprepro). To reproduce this pipeline, the scripts must be run on a high performance computer with a [_SLURM_-like](https://slurm.schedmd.com) cluster job scheduler, and with a local (to the high performance computer) copy of the UKB genetic data (i.e., UKB [Data-Field 22828](https://biobank.ctsu.ox.ac.uk/crystal/field.cgi?id=22828]) and associated Data-Fields). The input to this pipeline is a list of sample IDs (the study sample). The output is a preprocessed version of the UKB genetic data with the study sample split into a discovery cohort and a replication cohort. **ezprepro** is released under the BSD 2-Clause License. That license, and the copyright for **ezprepro**, are listed at the bottom of this _README_ file.

### Preprocessing

The preprocessing done by this pipeline consists of the following ordered list of operations:

- Subset the UKB genetic data to a provided list of samples (i.e., participants&mdash;these are the study samples for which the brain phenotype of interest is measured).

- Further subset to samples with white British ancestry (using the UKB variable *in.white.British*), without aneuploidy and with genetic sex matching reported sex.

- Further subset to a maximal subset of unrelated samples.

- Split the remaining samples into a discovery cohort with approximately 2/3 of the samples, and a replication cohort with approximately 1/3 of the samples.

- Subset the variants in the discovery cohort according to the filters: _MAF_ > 0.1% and _INFO_ > 0.3 and _HWE_ -log10 p-value <7.

- Subset the variants in the replication cohort to match the variants passing the filters for the discovery cohort.

This process results in files containing genotypes for the discovery cohort and the replication cohort on the autosomal chromosomes, the X chromosome, and the pseudoautosomal regions of the Y chromosomes. In addition to these genotypes, the pipeline also forms a version of these files stratified by genetic sex. 

### Execution

To run the **ezprepro** script, follow these steps:

- Step 1: Modify `ezprepro/bin/global.sh` and set the environmental variables to your system specific values.

- Step 2: Populate `ezprepro/bin/` with binaries (or symlinks to binaries) following the inventory in `ezprepro/bin/index.txt`.

- Step 3: With your current working directory set to `ezprepro/`, run the shell command `./A10.sh <STUDY.TXT>`. Here `<STUDY.TXT>` should be the path to a file containing the sample IDs of your study sample, with one sample ID per line.

- Step 4: Run all the remaining shell commands that end in `10.sh` in `ezprepro/` in lexigraphical order, with your current working directory still set to `ezprepro/`. These remaining shell commands (after `A10.sh`) have no command line arguments. (That is, run `./B10.sh`, ..., `./N10.sh`).

Each shell command will batch out jobs on _SLURM_, and then block until the jobs end. After running each shell command, you must examine the error and output logs of the jobs. For the shell command `./X10.sh`, the logs will be in `ezprepro/logs/X10/*`. Here `X` is the letter of the shell command that was run. If the error logs or output logs indicate a problem, fix the problem before proceeding. Errors may indicate incorrect settings in `ezprepro/bin/global.sh`, or [oom-killer](https://www.kernel.org/doc/gorman/html/understand/understand016.html) events or [walltime](https://slurm.schedmd.com/resource_limits.html)-exceeded events.

Note that not all of the software used in this pipeline can operate with set RAM limits, so if RAM usage exceeds the default limits on _SLURM_, you may need to modify the shell commands to specify limits. These modifications (to `*10.sh`) may be system-specific, providing names for projects, queues, or numbers for nodes. In general, modifying the _SLURM_ limits can be done by modifying the lines in each of the `*10.sh` scripts before each occurrence of the following echo command:

```
echo "T1=\$(date \"+%s\");" >> $file
```

Note that there is some variance in the syntax _SLURM_ implementations use to submit or query jobs, or to investigate failed jobs. Errors (likely appearing in the shell command's standard output) may indicate that the _SLURM_ syntax must be modified.

The **ezprepro** shell commands are approximately idempotent. Should you rerun a failed shell command, **ezprepro** will attempt to resume and only batch out portions of the shell command that failed. Should you rerun a successful shell command, **ezprepro** will attempt to not batch out any new jobs. By cross-referencing output and error logs with the conditional statements governing the resume-logic, you can determine if it is safe to rerun and resume the shell command. If it is not safe to resume (or if you are unable to determine the safety), then delete the intermediate files mentioned in the conditional statements governing the resume-logic before rerunning.

### Output

After all of the **ezprepro** shell commands run successfully, the output will be structured as follows:

- `ezprepro/genetics/disco2/chr01.{bgen,bgi,sample}` ... `ezprepro/genetics/disco2/chr22.{bgen,bgi,sample}`, `ezprepro/genetics/disco2/chrX.{bgen,bgi,sample}`, `ezprepro/genetics/disco2/chrXY.{bgen,bgi,sample}`: Genotypes for the discovery cohort for autosomes, pseudoautosomal X chromosome, and non-pseudoautosomal X chromosome (respectively), for variants passing the filters mentioned in the *Preprocessing* section above.

- `ezprepro/genetics/repro2/chr01.{bgen,bgi,sample}` ... `ezprepro/genetics/repro2/chr22.{bgen,bgi,sample}`, `ezprepro/genetics/repro2/chrX.{bgen,bgi,sample}`, `ezprepro/genetics/repro2/chrXY.{bgen,bgi,sample}`: Genotypes for the reproduction cohort.

- `ezprepro/genetics/disco3/chr01m.{bgen,bgi,sample}` ... `ezprepro/genetics/disco3/chr22m.{bgen,bgi,sample}`, `ezprepro/genetics/disco3/chrXm.{bgen,bgi,sample}`, `ezprepro/genetics/disco3/chrXYm.{bgen,bgi,sample}`, `ezprepro/genetics/repro3/chr01f.{bgen,bgi,sample}` ... `ezprepro/genetics/repro3/chr22f.{bgen,bgi,sample}`, `ezprepro/genetics/repro3/chrXf.{bgen,bgi,sample}`, `ezprepro/genetics/repro3/chrXYf.{bgen,bgi,sample}`: Genotypes for the discovery cohort (in the directory `disco3`) and reproduction cohort (in the directory `repro3`) stratified by genetic sex. The male genetic sex is indicated by the postfix `m` before the extension, and the female genetic sex is indicated by the postfix `f` before the extension.

All genotype files are provided in [indexed *bgen* v1.1 format](https://www.chg.ox.ac.uk/~gav/bgen_format/spec/v1.1.html), with indexing provided by [bgenix](https://enkre.net/cgi-bin/code/bgen/doc/trunk/doc/wiki/bgenix.md).


### Errors

- Due to a limitation in _qctool_ v1.4, the INFO filter might not be applied to the X chromosome genotype files. If univariate GWAS is subsequently performed (for example, through **ezgwas**), then the resulting summary statistics files may be further subset to apply the INFO filter.

- The second step of preprocessing described in the *Preprocessing* section should be modified to include people who are transgendered, people with aneuploidy, and people who do not have recent white British ancestry. This may be done either with further stratification (as is done in the output directories `disco3` and `repro3` for sex), or through further methods development allowing inclusion in downstream analyses without demographic confounding. Note that recent work suggests that UKB participants with mismatch between genetic sex and reported sex may be enriched with transgender people ([S.F. Ackley et al. 2023. Discordance in chromosomal and self-reported sex in the UK Biobank: Implications for transgender- and intersex-inclusive data collection](https://www.pnas.org/doi/abs/10.1073/pnas.2218700120)).

### Profiling

After the shell script `X10.sh` completes, the runtime for each batched-out job are recorded in seconds in the files `ezprepro/runtimes/X10/*` (here, `X` ranges over `A` ... `N`). The total runtime in days for the pipeline can thus be determined using the following bash command:

```
cat ezprepro/runtimes/*/* | awk '{ sum += $1 } END { printf "%.2f\n", sum/60/60/24 }'
```

Note that if a step is rerun, the previous runtimes are overwritten (and so while the result is the number of days of compute used to produce the output, this is an underestimate of the amount of compute used to execute the pipeline).



### License (BSD 2-Clause)

```
ezprepro

Copyright 2023 Lloyd T. Elliott, Stephen M. Smith, Gwenaëlle Douaud

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
