/* autoexec for t001_load_vdw_codebucket
 * Stages the two libraries the codebucket builder reads:
 *   dat.vdw_standard_codes  - a representative slice of the project's own
 *                             VDW standard-codes reference (code/code_type/
 *                             code_desc/code_source), sampled from the
 *                             sas_dat/vdw_standard_codes.sas7bdat shipped in
 *                             the repo.
 *   vocab.concept           - a small OMOP-vocabulary CONCEPT table standing
 *                             in for the externally-sourced Athena download
 *                             (omop_vocab\CONCEPT.csv) that 01-merge loads.
 *                             Covers several of the vocabulary_id values that
 *                             02-load-VDW-CB.sas selects on.
 * The codebucket-build PROC SQL in script.sas is the author's, unchanged.
 */
options obs=100;

/* dat.vdw_standard_codes : real sampled rows from the repo's reference table */
data dat_vdw_standard_codes;
  length code $13 code_type $23 code_desc $451 code_source $15;
  infile datalines dsd dlm='|';
  input code $ code_type $ code_desc $ code_source $;
  datalines;
C|CAUSETYPE|Contributory|CAUSE_OF_DEATH
10|DX_CODETYPE|ICD_10|CAUSE_OF_DEATH
B|GEOLEVEL|Block|CENSUS_LOCATION
0|MATCH_STRENGTH|No coordinates|CENSUS_LOCATION
E|CONFIDENCE|Excellent|DEATH
B|DTIMPUTE|Both month & day imputed|DEATH
N|HISPANIC|No|DEMOGRAPHICS
AS|RACE|Asian|DEMOGRAPHICS
F|SEX_ADMIN|Female|DEMOGRAPHICS
P|PRIMARY_DX|Primary diagnosis|DIAGNOSIS
AF|ADMITTING_SOURCE|Adult Foster Home|ENCOUNTER
ACUP|DEPARTMENT|Acupuncture|ENCOUNTER
ADMINS|DEPT|Administration|ENCOUNTER
A|DISCHARGE_DISPOSITION|Alive|ENCOUNTER
2160-0|TEST_TYPE|Creatinine|LAB_RESULTS
;
run;

/* vocab.concept : mock OMOP CONCEPT rows in the column shape the script reads.
 * vocabulary_id / domain_id chosen to exercise several branches of the union
 * (ICD9CM, ICD10CM, LOINC, CPT4-by-domain, HCPCS, RxNorm). Concept codes and
 * names are illustrative standard-vocabulary entries.
 */
data vocab_concept;
  length concept_id 8 concept_name $255 domain_id $20 vocabulary_id $20
         concept_class_id $20 standard_concept $1 concept_code $50
         valid_start_date $10 valid_end_date $10 invalid_reason $1;
  infile datalines dsd dlm='|';
  input concept_id concept_name $ domain_id $ vocabulary_id $ concept_class_id $
        standard_concept $ concept_code $ valid_start_date $ valid_end_date $ invalid_reason $;
  datalines;
44824287|Cholera due to Vibrio cholerae|Condition|ICD10CM|4-char billing code|S|A00.0|2007-01-01|2099-12-31|
44820001|Cholera due to Vibrio cholerae el tor|Condition|ICD9CM|3-dig billing code|S|001.1|1970-01-01|2099-12-31|
2002700001|Pneumonectomy|Procedure|ICD10PCS|7-char proc|S|0BTC0ZZ|2015-10-01|2099-12-31|
2000000001|Appendectomy|Procedure|ICD9Proc|4-dig proc|S|47.09|1970-01-01|2099-12-31|
3013682|Creatinine [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2160-0|1970-01-01|2099-12-31|
3024128|Hemoglobin A1c/Hemoglobin.total in Blood|Measurement|LOINC|Lab Test|S|4548-4|1970-01-01|2099-12-31|
2212345|Metabolic panel|Measurement|CPT4|CPT4|S|80053|1990-01-01|2099-12-31|
2008888|Office visit established patient|Observation|CPT4|CPT4|S|99213|1990-01-01|2099-12-31|
2599999|Ambulance service|Procedure|HCPCS|HCPCS|S|A0428|1990-01-01|2099-12-31|
19019073|Ibuprofen 200 MG Oral Tablet|Drug|RxNorm|Clinical Drug|S|310965|1970-01-01|2099-12-31|
;
run;
