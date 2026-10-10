# HCSRN_Lab_Code_Management
Code that produces views of the relationships between Lab Codes and Lab Code Hierarchies

## Prerequisites
### An HCSRN-VDW Common Data Model
- You'll need an HCSRN-VDW Lab Results table in order for the Code Management Interface with LOINC Terminology to be useful. The code itself can be run without an HCSRN VDW Lab Results table.

### The ability to download the OHDSI OMOP Vocabulary files
- If you can connect with OHDSI OMOP Vocabulary by going to [Athena](https://athena.ohdsi.org/vocabulary/list) then you have the ability to get OHDSI OMOP Vocabulary data.

## Implementation Directions
1. Clone HCSRN_Lab_Code_Management (... this project) to a local directory
2. Download OHDSI OMOP Vocabulary LOINC related vocabularies from Athena
   1. The recommended vocabularies are:
      * 6-LOINC
      * 4-CPT4 (Optional - requires license)
      * 5-HCPCS (Optional)
      * 1-SNOMED CT (Optional)
   2. After downloading zip file; unzip the CSV files into the omop_vocab folder
3. Edit Runtime Parameter Variables
   1. Save the file "./sas_etl/0-edit-run-main.sas" to "0-run-main.sas"
   2. Edit the file "./sas_etl/0-run-main.sas" to use your local settings
4. Run the file "0-run-main.sas" that you have edited to align with your SAS environment
