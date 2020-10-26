#!/bin/bash
# ============================================================================
# Developing brain Region Annotation With Expectation-Maximization (Draw-EM)
#
# Copyright 2013-2016 Imperial College London
# Copyright 2013-2016 Andreas Schuh
# Copyright 2013-2016 Antonios Makropoulos
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================


[ $# -ge 2 ] || { echo "usage: $(basename "$0") <subject> <age> [<#jobs>]" 1>&2; exit 1; }
subj=$1
age=$2
njobs=1
if [ $# -gt 2 ];then njobs=$3;fi

sdir=segmentations-data
if [ ! -f $sdir/tissue-initial-segmentations/$subj.nii.gz ];then
    echo "creating $subj tissue priors"

    mkdir -p $sdir $sdir/template $sdir/tissue-posteriors $sdir/tissue-initial-segmentations || exit 1
    structures="csf gm wm outlier ventricles cerebstem dgm hwm lwm"
    for str in ${structures};do
    mkdir -p $sdir/template/$str $sdir/tissue-posteriors/$str || exit 1
    done

    strnum=0
    emsstructures=""
    emsposts=""

    for str in ${structures};do
    emsposts="$emsposts -saveprob $strnum $sdir/tissue-posteriors/$str/$subj.nii.gz"
    strnum=$(($strnum+1))

    strems=$sdir/template/$str/$subj.nii.gz
    run mirtk transform-image $DRAWEMDIR/atlases/non-rigid-v2/atlas-9/structure$strnum/$age.nii.gz $strems -dofin dofs/$subj-template-$age-n.dof.gz -target N4/$subj.nii.gz -interp Linear
    emsstructures="$emsstructures $strems"
    done

    mkdir -p logs
    run mirtk draw-em N4/$subj.nii.gz 9 $emsstructures $sdir/tissue-initial-segmentations/$subj.nii.gz -padding 0 -mrf $DRAWEMDIR/parameters/connectivities_tissues.mrf -tissues 1 3 1 0 1 1 3 2 7 8 -hui -relaxtimes 2 $emsposts  1>logs/$subj-tissue-em 2>logs/$subj-tissue-em-err

    mkdir -p $sdir/gm-posteriors || exit 1
    run mirtk calculate $sdir/tissue-posteriors/gm/$subj.nii.gz -mul 100 -out $sdir/gm-posteriors/$subj.nii.gz 
fi
