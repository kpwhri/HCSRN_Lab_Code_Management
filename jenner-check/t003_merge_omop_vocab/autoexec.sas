/* autoexec for t003_merge_omop_vocab
 * 01-merge-omop-vocab.sas loads a freshly-downloaded OMOP CONCEPT extract and
 * folds it into the existing OMOP vocabulary, keeping only concept_ids that
 * are not already present. To exercise the "vocabulary already exists" merge
 * branch (the interesting one), this autoexec stages two work tables:
 *   vocab.concept       - the existing OMOP CONCEPT table from a prior load.
 *   vocab.concept_temp  - the newly-downloaded extract, with some concept_ids
 *                         overlapping the existing table and some new.
 * In the project, vocab.concept_temp is read from omop_vocab\CONCEPT.csv via
 * INFILE; here it is staged inline so the bundle is self-contained. The merge,
 * %sysfunc(exist()) guard, and PROC DATASETS promotion in script.sas are the
 * author's, unchanged. Two-level vocab. names map to the work tables below.
 */
options obs=100;

/* vocab.concept : the OMOP CONCEPT table that already exists from a prior run */
data vocab_concept;
  length concept_id 8 concept_name $255 domain_id $20 vocabulary_id $20
         concept_class_id $20 standard_concept $1 concept_code $50
         valid_start_date $10 valid_end_date $10 invalid_reason $1;
  infile datalines dsd dlm='|';
  input concept_id concept_name $ domain_id $ vocabulary_id $ concept_class_id $
        standard_concept $ concept_code $ valid_start_date $ valid_end_date $ invalid_reason $;
  datalines;
3013682|Creatinine [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2160-0|1970-01-01|2099-12-31|
3024128|Hemoglobin A1c/Hemoglobin.total in Blood|Measurement|LOINC|Lab Test|S|4548-4|1970-01-01|2099-12-31|
3004501|Glucose [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2345-7|1970-01-01|2099-12-31|
;
run;

/* vocab.concept_temp : the freshly-downloaded Athena extract.
 * 3013682 and 3024128 already exist (should be filtered out by the merge);
 * 3016723 and 3020891 are new (should be added).
 */
data vocab_concept_temp;
  length concept_id 8 concept_name $255 domain_id $20 vocabulary_id $20
         concept_class_id $20 standard_concept $1 concept_code $50
         valid_start_date $10 valid_end_date $10 invalid_reason $1;
  infile datalines dsd dlm='|';
  input concept_id concept_name $ domain_id $ vocabulary_id $ concept_class_id $
        standard_concept $ concept_code $ valid_start_date $ valid_end_date $ invalid_reason $;
  datalines;
3013682|Creatinine [Mass/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2160-0|1970-01-01|2099-12-31|
3024128|Hemoglobin A1c/Hemoglobin.total in Blood|Measurement|LOINC|Lab Test|S|4548-4|1970-01-01|2099-12-31|
3016723|Sodium [Moles/volume] in Serum or Plasma|Measurement|LOINC|Lab Test|S|2951-2|1970-01-01|2099-12-31|
3020891|Body temperature|Measurement|LOINC|Clinical|S|8310-5|1970-01-01|2099-12-31|
;
run;
