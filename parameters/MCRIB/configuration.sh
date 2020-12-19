#!/bin/bash
# ============================================================================
# Developing brain Region Annotation With Expectation-Maximization (Draw-EM)
#
# Copyright 2013-2020 Imperial College London
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

export HIGH_WM_VENTRICLE_CORRECTION=0
export HEMISPHERE_HOLE_CORRECTION=1

export CONNECTIVITIES=$DRAWEMDIR/parameters/MCRIB/connectivities.mrf
export LOOKUP_TABLE=$DRAWEMDIR/parameters/MCRIB/LUT.txt
export ATLAS_T2_DIR=$DRAWEMDIR/atlases/M-CRIB_2.0/T2
export ATLAS_TISSUES_DIR=$DRAWEMDIR/atlases/M-CRIB_2.0/tissues
export ATLAS_SEGMENTATIONS_DIR=$DRAWEMDIR/atlases/M-CRIB_2.0/segmentations
export ATLAS_GM_POSTERIORS_DIR=""
export ATLASES=`ls $ATLAS_T2_DIR | sed -e 's:.nii.gz::g'`
export ATLAS_TISSUES="csf gm wm outlier"
export OUTLIER_TISSUES=outlier
export CSF_TISSUES=csf
export GM_TISSUES=gm
export WM_TISSUES=wm
export HIGH_WM_TISSUE=

####### The following are needed for the dHCP pipeline surface reconstruction #######
export CSF_TISSUE_LABEL=1
export GM_TISSUE_LABEL=2
export WM_TISSUE_LABEL=3
export BG_TISSUE_LABEL=4

export HIPPOCAMPI="17 18"
export AMYGDALA="53 54"
export DEEP_SUBCORTICAL_GM="9 11 12 13 26 48 50 51 52 58"
export DEEP_GM="$DEEP_SUBCORTICAL_GM $HIPPOCAMPI $AMYGDALA"
export CORPUS_CALLOSUM="192"
export BRAINSTEM="170 28 60"
export CEREBELLUM="75 76 90 91 93"
#####################################################################################

export CSF_LABEL=24
export OUTLIER_LABEL=4000
export CORTICAL_WM="2 41"
export CORTICAL_GM="1000 1001 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 2000 2001 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035"
export CORTICAL="$CORTICAL_GM $CORTICAL_WM"
export VENTRICLES="4 43"
export NONCORTICAL="$DEEP_GM $VENTRICLES $BRAINSTEM $CEREBELLUM $CORPUS_CALLOSUM 14 15"
export ALL_LABELS="$OUTLIER_LABEL $CSF_LABEL $CORTICAL $NONCORTICAL"
export LEFT_HEMI_LABELS="91 1000 1001 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 2 4 9 11 12 13 17 18 26 28"
export RIGHT_HEMI_LABELS="93 2000 2001 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 41 43 48 50 51 52 53 54 58 60"
export ALL_LABELS_TO_LABELS="1 4000 0"
export ALL_LABELS_TO_TISSUE_LABELS="3 24 14 15 1 70 1000 1001 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 2000 2001 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2 2 2 41 3 1 4000 4 2 4 43 5 5 75 76 90 91 93 6 11 11 12 13 192 26 48 50 51 52 58 9 7 3 170 28 60 8 4 17 53 18 54 9"
export WHITE_SURFACE_TISSUE_LABELS="$WM_TISSUE_LABEL 5 7 9"
export PIAL_SURFACE_TISSUE_LABELS="$WHITE_SURFACE_TISSUE_LABELS $GM_TISSUE_LABEL"
