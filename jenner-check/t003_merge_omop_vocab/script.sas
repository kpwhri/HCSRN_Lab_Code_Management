/*********************************************
* Adapted from sas_etl/01-merge-omop-vocab.sas
* Purpose:: Load the CSV files produced by OHDSI Athena and fold new OMOP
*           CONCEPT rows into the existing vocabulary.
*
* This is the project's incremental-load pattern for the CONCEPT table:
* a %sysfunc(exist()) guard chooses between a first-run load and a merge that
* unions the existing rows with only the genuinely-new extract rows (an
* anti-join on concept_id), then PROC DATASETS promotes the staged *_in table
* to the live name. The logic below is the author's, unchanged in structure;
* the two-level vocab. library name is mapped to the work tables that
* autoexec.sas stages (vocab_concept and vocab_concept_temp).
*********************************************/

/* Process and Load New Concepts into Concept table  */
%if %sysfunc( exist(vocab_concept) ) %then %do;
  proc sql;
  create table vocab_concept_in as
    select cp.* from vocab_concept cp
    union
    select ctp.*
    from vocab_concept_temp ctp
    left outer join vocab_concept oct
    on ctp.concept_id = oct.concept_id
      where oct.concept_id is null;
  quit;
%end;
%else %do;
  proc sql;
    create table vocab_concept_in as
    select ctp.*
      from vocab_concept_temp ctp;
  quit;
%end;

/* Delete the staging extract */
proc datasets library=work nolist;
  delete vocab_concept_temp;
quit;

/* Move the previous CONCEPT to a backup name */
proc datasets library=work nolist;
  change vocab_concept=vocab_concept_bkup;
quit;

/* Promote the merged input table to the live CONCEPT name */
proc datasets library=work nolist;
  change vocab_concept_in=vocab_concept;
quit;

/* Show the merged vocabulary: the three existing concepts plus the two new
 * ones, with no duplicates of the overlapping concept_ids. */
proc sql;
  select count(*) as concept_rows_after_merge from vocab_concept;
quit;

proc print data=vocab_concept;
  var concept_id concept_code vocabulary_id concept_name;
run;
