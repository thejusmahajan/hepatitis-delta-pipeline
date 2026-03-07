# Hepatitis Delta Virus Sequence Analysis Pipeline

A Nextflow pipeline for hepatitis delta virus sequence analysis.

## Pipeline Overview
1. **DOWNLOAD_REFERENCE**: Fetches references from NCBI using an accession number via Entrez Direct.
2. **COMBINE**: Combines input FASTA files.
3. **ALIGN**: Aligns the combined sequences using MAFFT.
4. **TRIMAL**: Cleans the alignment using trimAl and generates an HTML report.

## Requirements
- Nextflow (DSL2 enabled)
- Conda (environments handle `entrez-direct`, `mafft`, and `trimal`)

## Usage
Run the pipeline by pointing it to a directory containing your input FASTA files and providing a reference accession:
```bash
nextflow run main.nf --in <path/to/fasta/dir> --accession <NCBI_ACCESSION>
```
