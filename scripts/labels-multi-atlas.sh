#!/bin/bash
# ============================================================================
# Developing brain Region Annotation With Expectation-Maximization (Draw-EM)
#
# Copyright 2013-2020 Imperial College London
# Copyright 2013-2020 Andreas Schuh
# Copyright 2013-2020 Antonios Makropoulos
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


[ $# -eq 1 ] || { echo "usage: $(basename "$0") <subject>" 1>&2; exit 1; }
subj=$1

sdir=segmentations-data

if [ ! -f $sdir/MADs/$subj-subspace.nii.gz ];then
    mkdir -p $sdir/MADs $sdir/transformations $sdir/atlas-weights  || exit 1 
    for r in ${ALL_LABELS};do mkdir -p $sdir/labels/seg$r || exit 1; done
    for str in ${ATLAS_TISSUES};do mkdir -p $sdir/labels/$str || exit 1; done

    sigma=10000
    run mirtk convert-image N4/$subj.nii.gz $sdir/atlas-weights/$subj-normalized.nii.gz -rescale 0 200 -double 

    #for each atlas
    for atlas in ${ATLASES};do
        if [ ! -f dofs/$subj-$atlas-n.dof.gz ];then continue;fi

        #transform atlas labels
        if [ ! -f $sdir/transformations/$subj-$atlas.nii.gz ];then 
            ms=$sdir/template/$str/$subj.nii.gz
            run mirtk transform-image $ATLAS_SEGMENTATIONS_DIR/$atlas.nii.gz $sdir/transformations/$subj-$atlas.nii.gz -target N4/$subj.nii.gz -dofin dofs/$subj-$atlas-n.dof.gz -interp NN 
        fi
        if [ ! -f $sdir/transformations/tissues-$subj-$atlas.nii.gz ];then 
            ms=$sdir/template/$str/$subj.nii.gz
            run mirtk transform-image $ATLAS_TISSUES_DIR/$atlas.nii.gz $sdir/transformations/tissues-$subj-$atlas.nii.gz -target N4/$subj.nii.gz -dofin dofs/$subj-$atlas-n.dof.gz -interp NN 
        fi

        #transform atlases
        if [ ! -f $sdir/transformations/T2-$subj-$atlas.nii.gz ];then 
            ms=$sdir/template/$str/$subj.nii.gz
            run mirtk transform-image $ATLAS_T2_DIR/$atlas.nii.gz $sdir/transformations/T2-$subj-$atlas.nii.gz -target N4/$subj.nii.gz -dofin dofs/$subj-$atlas-n.dof.gz -interp BSpline 
        fi

        #weight atlas locally
        if [ ! -f $sdir/atlas-weights/$subj-$atlas.nii.gz ];then 
            run mirtk normalize N4/$subj.nii.gz $sdir/transformations/T2-$subj-$atlas.nii.gz $sdir/atlas-weights/$subj-$atlas-normalized.nii.gz -piecewise 
            run mirtk convert-image $sdir/atlas-weights/$subj-$atlas-normalized.nii.gz $sdir/atlas-weights/$subj-$atlas-normalized.nii.gz -rescale 0 200 -double 
            # This calculates weights based on a gaussian distance.
            run mirtk calculate $sdir/atlas-weights/$subj-normalized.nii.gz -sub $sdir/atlas-weights/$subj-$atlas-normalized.nii.gz -sq -out $sdir/atlas-weights/$subj-$atlas.nii.gz 
            run mirtk calculate-filtering $sdir/atlas-weights/$subj-$atlas.nii.gz -kernel 3 -mean $sdir/atlas-weights/$subj-$atlas.nii.gz  
            run mirtk calculate $sdir/atlas-weights/$subj-$atlas.nii.gz -mul -27 -div $sigma -out $sdir/atlas-weights/$subj-$atlas.nii.gz  
            run mirtk calculate $sdir/atlas-weights/$subj-$atlas.nii.gz -exp -out $sdir/atlas-weights/$subj-$atlas.nii.gz  
            # smooth the weights
            run mirtk calculate-filtering $sdir/atlas-weights/$subj-$atlas.nii.gz -kernel 3 -median $sdir/atlas-weights/$subj-$atlas.nii.gz  
            rm -f $sdir/atlas-weights/$subj-$atlas-normalized.nii.gz
        fi
    done

    rm -f $sdir/atlas-weights/$subj-normalized.nii.gz


    #split labels
    transformed=""
    transformedc=""
    transformedw=""
    for atlas in ${ATLASES};do 
        transformed="$transformed $sdir/transformations/$subj-$atlas.nii.gz";
        transformedc="$transformedc $sdir/transformations/tissues-$subj-$atlas.nii.gz";
        transformedw="$transformedw $sdir/atlas-weights/$subj-$atlas.nii.gz";
    done

    num=`echo $ATLASES | wc -w`
    splitnum=0
    splitstr=""; 
    for r in ${NONCORTICAL} ${CORTICAL};do let splitnum=splitnum+1; splitstr=$splitstr" $r"; done
    for r in ${NONCORTICAL} ${CORTICAL};do splitstr=$splitstr" $sdir/labels/seg$r/$subj.nii.gz"; done
    run mirtk split-labels $num $transformed $transformedw  $splitnum $splitstr 

    splitnum=0
    splitstr=""; 
    for str in ${ATLAS_TISSUES};do let splitnum=splitnum+1; splitstr=$splitstr" $splitnum"; done
    for str in ${ATLAS_TISSUES};do splitstr=$splitstr" $sdir/labels/$str/$subj.nii.gz"; done
    run mirtk split-labels $num $transformedc $transformedw  $splitnum $splitstr

    if [ "$ATLAS_NAME" == "ALBERT" ];then
        #remove CC from WM
        mirtk calculate $sdir/labels/wm/$subj.nii.gz -sub $sdir/labels/seg48/$subj.nii.gz -clamp-below 0 -out $sdir/labels/wm/$subj.nii.gz
        # in ALBERTs cortical labels cover both WM and GM, copy cortical GM structures as WM structures too
        cortical_wm_arr=($CORTICAL_WM)
        cortical_gm_arr=($CORTICAL_GM)
        for ((n=0;n<${#cortical_gm_arr[*]};n++));do
            gm_structure=${cortical_gm_arr[$n]};
            wm_structure=${cortical_wm_arr[$n]};
            cp $sdir/labels/seg$gm_structure/$subj.nii.gz $sdir/labels/seg$wm_structure/$subj.nii.gz
        done
    fi

    #create MAD
    if [ ! -f $sdir/MADs/$subj.nii.gz ];then 
        nn=5
        run mirtk calculate-gradients N4/$subj.nii.gz $sdir/MADs/$subj-grad.nii.gz 0 
        run mirtk calculate-filtering $sdir/MADs/$subj-grad.nii.gz -kernel $nn -median $sdir/MADs/$subj-cur.nii.gz  
        run mirtk calculate $sdir/MADs/$subj-grad.nii.gz -sub $sdir/MADs/$subj-cur.nii.gz -abs -out $sdir/MADs/$subj-cur.nii.gz 
        run mirtk calculate-filtering  $sdir/MADs/$subj-cur.nii.gz -kernel $nn -median $sdir/MADs/$subj-cur.nii.gz  
        run mirtk calculate $sdir/MADs/$subj-grad.nii.gz -div-with-zero $sdir/MADs/$subj-cur.nii.gz -div 1.4826 -sq -mul 0.5 -add 1 -log -out $sdir/MADs/$subj-cur.nii.gz 
        run mirtk calculate N4/$subj.nii.gz -div-with-zero N4/$subj.nii.gz -mul $sdir/MADs/$subj-cur.nii.gz  -add 1 -out $sdir/MADs/$subj-cur.nii.gz 
        run mirtk calculate $sdir/MADs/$subj-cur.nii.gz -mul 0 -add 1 -div-with-zero $sdir/MADs/$subj-cur.nii.gz -out $sdir/MADs/$subj.nii.gz 
        rm -f $sdir/MADs/$subj-cur.nii.gz
    fi

    #create posterior penalty
    str="";
    for i in ${NONCORTICAL};do str="$str-add $sdir/labels/seg$i/$subj.nii.gz "; done
    str=`echo $str| sed -e 's:^\-add ::g'`
    run mirtk calculate $str -div 100 -mul $sdir/MADs/$subj.nii.gz -out $sdir/MADs/$subj-subspace.nii.gz 
fi
