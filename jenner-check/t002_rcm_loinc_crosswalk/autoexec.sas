/* autoexec for t002_rcm_loinc_crosswalk
 * Stages the three inputs 03-load-RCM.sas reads:
 *   dat.vdw_codebucket          - the codebucket table that 02-load-VDW-CB.sas
 *                                 produces; here a small slice that includes
 *                                 LOINC-typed rows so the first join matches.
 *   vocab.concept               - OMOP CONCEPT rows: the LOINC lab concepts
 *                                 plus the "LOINC Group" parent concepts that
 *                                 the second query subsumes to.
 *   vocab.concept_relationship  - OMOP CONCEPT_RELATIONSHIP 'Subsumes' edges
 *                                 from each LOINC Group concept to its member
 *                                 LOINC concepts.
 * The two crosswalk PROC SQL queries in script.sas are the author's, unchanged.
 * Two-level dat./vocab. names are mapped to the work tables below.
 */
options obs=100;

/* dat.vdw_codebucket : codebucket rows incl. LOINC-typed entries.
 * code_id values mirror the monotonic() ids 02-load-VDW-CB.sas assigns.
 */
data dat_vdw_codebucket;
  length code_id 8 code $50 code_type $23 code_desc $255 code_source $15;
  infile datalines dsd dlm='|';
  input code_id code $ code_type $ code_desc $ code_source $;
  datalines;
101|2160-0|LOINC|Creatinine [Mass/volume] in Serum or Plasma|OMOP_LAB_RESULTS
102|4548-4|LOINC|Hemoglobin A1c/Hemoglobin.total in Blood|OMOP_LAB_RESULTS
103|2345-7|LOINC|Glucose [Mass/volume] in Serum or Plasma|OMOP_LAB_RESULTS
104|99213|CPT4|Office visit established patient|OMOP_OBSERVATION
105|A0428|HCPCS|Ambulance service|OMOP_OBSERVATION
;
run;

/* vocab.concept : LOINC lab concepts + their LOINC Group parents. */
data vocab_concept;
  length concept_id 8 concept_name $255 domain_id $20 vocabulary_id $20
         concept_class_id $20 standard_concept $1 concept_code $50;
  infile datalines dsd dlm='|';
  input concept_id concept_name $ domain_id $ vocabulary_id $ concept_class_id $
        standard_concept $ concept_code $;
  datalines;
3013682|Creatinine [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2160-0
3024128|Hemoglobin A1c/Hemoglobin.total in Blood|Measurement|LOINC|Lab Test|S|4548-4
3004501|Glucose [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2345-7
40789207|Creatinine [Bld-sCnc]|Measurement|LOINC|LOINC Group|S|LG6657-3
40782521|Hemoglobin A1c [Bld]|Measurement|LOINC|LOINC Group|S|LG5832-3
40789169|Glucose [Bld-sCnc]|Measurement|LOINC|LOINC Group|S|LG7967-5
;
run;

/* vocab.concept_relationship : 'Subsumes' edges from each LOINC Group to
 * its member LOINC concept (concept_id_1 = group, concept_id_2 = member).
 */
data vocab_concept_relationship;
  length concept_id_1 8 concept_id_2 8 relationship_id $20
         valid_start_date $10 valid_end_date $10 invalid_reason $1;
  infile datalines dsd dlm='|';
  input concept_id_1 concept_id_2 relationship_id $
        valid_start_date $ valid_end_date $ invalid_reason $;
  datalines;
40789207|3013682|Subsumes|1970-01-01|2099-12-31|
40782521|3024128|Subsumes|1970-01-01|2099-12-31|
40789169|3004501|Subsumes|1970-01-01|2099-12-31|
40789207|3013682|Maps to|1970-01-01|2099-12-31|
;
run;
