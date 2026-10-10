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

/*  This code updates the vdw_standard_codes data set when a new everloinc file is released
%let eldate = 20260421;

proc sql;
  create table dat.vdw_stdcodes_update as
    select sc.test_type as code, 'TEST_TYPE' as code_type, sc.LongName as code_desc, 'LAB_RESULTS' as code_source
    from (
    select distinct test_type, LongName
    from dat.everloinc_&eldate.
    except
    select code as test_type, code_desc as LongName
    from dat.vdw_standard_codes
    where code_type = 'TEST_TYPE'
    ) sc
    UNION
    select vsc.code, vsc.code_type, vsc.code_desc, vsc.code_source
    from dat.vdw_standard_codes vsc
    ;
quit;

proc datasets library=dat;
  change vdw_standard_codes=vdw_stdcodes_old;
run;

proc datasets library=dat;
  change vdw_stdcodes_update=vdw_standard_codes;
run;
*/

    
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



