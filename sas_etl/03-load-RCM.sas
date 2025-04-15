/*********************************************
* John Weeks
* Kaiser Permanente Washington Health Research Institute
* (206) 287-2711
* John.M.Weeks@kp.org
*
*
*
* Purpose:: Builds RCM Code Views
* Date Created:: 2020-10-01
*********************************************/

* maps vdw loinc codes to omop loinc codes;
proc sql;
  create table dat.rcm_lab_loinc as 
	select lr.code_id as vdw_code_id, lr.code as vdw_code, lr.code_desc as vdw_cd_desc, lr.code_type as vdw_cd_type,
	  cp.concept_id as omop_code_id, cp.concept_code as omop_code, cp.concept_name as omop_cd_desc, cp.vocabulary_id as omop_cd_type
	from dat.vdw_codebucket lr
	left join vocab.concept cp
	on cp.concept_code = lr.code
	where cp.vocabulary_id = 'LOINC'
    and lower(lr.code_type) = 'loinc'
    ;
quit;


* maps omop loinc codes to loinc group codes;
proc sql;
  create table dat.rcm_lab_loinc_group as
select crt.*, cpt.concept_code as loinc_code, cpt.concept_class_id as loinc_class, cpt.concept_name as loinc_desc
from vocab.concept cpt
inner join
(
select cr.*, lg.concept_id, lg.concept_name as loinc_group_desc, lg.concept_class_id as loinc_group_class, lg.concept_code as loinc_group_code
from vocab.concept_relationship cr
inner join
(select * from vocab.concept where concept_class_id = 'LOINC Group') lg
on cr.concept_id_1 = lg.concept_id
where cr.relationship_id = 'Subsumes'
) crt
on cpt.concept_id = crt.concept_id_2
    ;
quit;


* ;
