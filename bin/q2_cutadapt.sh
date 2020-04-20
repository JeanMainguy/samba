#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Script name: q2_cutadapt.sh                                             ####
##                                                                           ##
## Purpose of script: Remove primers in raw sequences                        ##
##                                                                           ##
##                                                                           ##
##                                                                           ##
## Authors: Laure QUINTRIC and Cyril NOEL                                  ####
##          Bioinformatics engineers                                         ##
##          SeBiMER, Ifremer                                                 ##
##                                                                           ##
## Creation Date: 2019-08-29                                               ####
## Modified on: 2020-01-31                                                 ####
##                                                                           ##
## Email: samba-sebimer@ifremer.fr                                         ####
##                                                                           ##
## Copyright (c) SeBiMER, august-2019                                      ####
## This program is free software: you can redistribute it and/or modify it   ##
## under the terms of the GNU Affero General Public License as published by  ##
## the Free Software Foundation, either version 3 of the License, or         ##
## (at your option) any later version.                                       ## 
##                                                                           ##
## License at https://www.gnu.org/licenses/agpl-3.0.txt                      ##
##                                                                           ##
## This program is distributed in the hope that it will be useful, but       ##
## WITHOUT ANY WARRANTY; without even the implied warranty of                ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                      ##
## See the GNU Affero General Public License for more details.               ##
##                                                                           ##
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## Command run by nextflow :
## q2_cutadapt.sh ${task.cpus} ${imported_data} ${params.cutadapt.primerF} ${params.cutadapt.primerR} ${params.cutadapt.errorRate} ${params.cutadapt.overlap} data_trimmed.qza data_trimmed.qzv trimmed_output completecmd > q2_cutadapt.log 2>&1

# Arguments 
args=("$@")

singleEnd=${args[0]}
cpus=${args[1]}
imported_data=${args[2]}
primerF=${args[3]}
primerR=${args[4]}
errorRate=${args[5]}
overlap=${args[6]}
data_trimmedqza=${args[7]}
data_trimmedqzv=${args[8]}
trimmed_output=${args[9]}
logcmd=${args[10]}

#Run cutadapt
if ${singleEnd}; then
    cmdoptions="qiime cutadapt trim-single --p-front $primerF"
else
    cmdoptions="qiime cutadapt trim-paired --p-front-f $primerF --p-front-r $primerR" 
fi
cmd="$cmdoptions \
    --verbose \
    --p-cores $cpus \
    --i-demultiplexed-sequences $imported_data \
    --p-error-rate $errorRate \
    --p-discard-untrimmed --p-match-read-wildcards \
    --p-overlap $overlap \
    --o-trimmed-sequences $data_trimmedqza"

echo $cmd > $logcmd
eval $cmd

#Summarize counts per sample for all samples
cmd="qiime demux summarize \
    --verbose \
    --i-data $data_trimmedqza \
    --o-visualization $data_trimmedqzv"
echo $cmd >> $logcmd
eval $cmd

#Export html report
cmd="qiime tools export \
    --input-path $data_trimmedqzv \
    --output-path $trimmed_output"
echo $cmd >> $logcmd
eval $cmd

