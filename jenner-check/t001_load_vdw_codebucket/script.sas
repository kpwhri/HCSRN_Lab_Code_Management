/*********************************************
* Adapted from sas_etl/02-load-VDW-CB.sas
* Purpose:: Create the VDW Codebucket from VDW Codes and OMOP Codes
*
* The codebucket-build PROC SQL below is the project's own, unchanged in
* structure: monotonic() row id, and a union that tags each OMOP
* vocabulary_id/domain_id combination with its VDW code_type and code_source.
* The two source tables (the project's VDW standard codes and the OMOP
* CONCEPT table) are staged in autoexec.sas as dat_vdw_standard_codes and
* vocab_concept; the two-level dat./vocab. library names are mapped to those.
*********************************************/

proc sql;
  create table vdw_codebucket as
    select monotonic() as code_id, cds.* from (
    select code, code_type, code_desc, code_source from dat_vdw_standard_codes
    union
    select concept_code as code, 'ICD09CM' as code_type, concept_name as code_desc, 'OMOP_DIAGNOSIS' as code_source
    from vocab_concept where lower(vocabulary_id) = 'icd9cm'
    union
    select concept_code as code, 'ICD10CM' as code_type, concept_name as code_desc, 'OMOP_DIAGNOSIS' as code_source
    from vocab_concept where lower(vocabulary_id) = 'icd10cm'
    union
    select concept_code as code, '10' as code_type, concept_name as code_desc, 'OMOP_PROCEDURE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'icd10pcs'
    union
    select concept_code as code, '09' as code_type, concept_name as code_desc, 'OMOP_PROCEDURE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'icd9proc'
    union
    select concept_code as code, 'C4' as code_type, concept_name as code_desc, 'OMOP_PROCEDURE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'cpt4' and lower(domain_id) = 'procedure'
    union
    select concept_code as code, 'CPT4' as code_type, concept_name as code_desc, 'OMOP_OBSERVATION' as code_source
    from vocab_concept where lower(vocabulary_id) = 'cpt4' and lower(domain_id) = 'observation'
    union
    select concept_code as code, 'CPT4' as code_type, concept_name as code_desc, 'OMOP_MEASUREMENT' as code_source
    from vocab_concept where lower(vocabulary_id) = 'cpt4' and lower(domain_id) = 'measurement'
    union
    select concept_code as code, 'H4' as code_type, concept_name as code_desc, 'OMOP_PROCEDURE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'hcpcs' and lower(domain_id) = 'procedure'
    union
    select concept_code as code, 'HCPCS' as code_type, concept_name as code_desc, 'OMOP_OBSERVATION' as code_source
    from vocab_concept where lower(vocabulary_id) = 'hcpcs' and lower(domain_id) = 'observation'
    union
    select concept_code as code, 'HCPCS' as code_type, concept_name as code_desc, 'OMOP_DEVICE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'hcpcs' and lower(domain_id) = 'device'
    union
    select concept_code as code, 'HCPCS' as code_type, concept_name as code_desc, 'OMOP_DRUG' as code_source
    from vocab_concept where lower(vocabulary_id) = 'hcpcs' and lower(domain_id) = 'drug'
    union
    select concept_code as code, 'LOINC' as code_type, concept_name as code_desc, 'OMOP_LAB_RESULTS' as code_source
    from vocab_concept where lower(vocabulary_id) = 'loinc'
    union
    select concept_code as code, 'RV' as code_type, concept_name as code_desc, 'OMOP_PROCEDURE' as code_source
    from vocab_concept where lower(vocabulary_id) = 'revenue code'
    union
    select concept_code as code, 'NDC' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab_concept where lower(vocabulary_id) = 'ndc'
    union
    select concept_code as code, 'RxNorm' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab_concept where lower(vocabulary_id) = 'rxnorm'
    union
    select concept_code as code, 'RxNorm_Extension' as code_type, concept_name as code_desc, 'OMOP_PHARMACY' as code_source
    from vocab_concept where lower(vocabulary_id) = 'rxnorm extension'
    ) cds
    ;
quit;

/* Show the assembled codebucket and the per-source tally it produces. */
proc freq data=vdw_codebucket;
  tables code_source / nocum;
run;

proc print data=vdw_codebucket (obs=25);
  var code_id code code_type code_desc code_source;
run;
