# Hepatitis Delta Virus Sequence Analysis Pipeline

[![CI](https://github.com/thejusmahajan/hepatitis-delta-pipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/thejusmahajan/hepatitis-delta-pipeline/actions/workflows/ci.yml)

A small Nextflow (DSL2) pipeline for hepatitis delta virus sequences. It takes a folder of FASTA files, adds the reference genome M21012 from NCBI, aligns all sequences with MAFFT, removes poorly aligned columns with trimAl and writes a short summary table. It began as the final project of a bioinformatics course. Every step runs in a pinned container (Docker or Apptainer), and the tests run on GitHub Actions.

## Steps
1. **DOWNLOAD_REFERENCE**: fetches the reference from NCBI by accession with Entrez Direct. Skipped when `--reference` is given.
2. **COMBINE**: joins the input FASTA files and the reference into one file.
3. **ALIGN**: aligns all sequences with MAFFT (default FFT-NS-2).
4. **TRIMAL**: removes poorly aligned columns with trimAl `-automated1` and writes an HTML report.
5. **SUMMARY**: writes `summary.tsv` with the length of each input sequence and how much of the alignment trimAl kept.

## Quick start
Requires Nextflow (tested with 26.10.4) and Docker. Build the image for the summary step once, then run on the example data in `data/` with the bundled reference:
```bash
docker build -t hdv-summary:0.1.0 containers/summary
nextflow run main.nf -profile test,docker
```

On a cluster without Docker, use Apptainer:
```bash
nextflow run main.nf -profile test,apptainer
```
Apptainer pulls the BioContainers images itself. The summary image is not in a registry: save it where Docker runs (`docker save hdv-summary:0.1.0 -o hdv-summary.tar`) and convert it into Nextflow's image cache on the cluster:
```bash
apptainer build "$NXF_APPTAINER_CACHEDIR/hdv-summary-0.1.0.img" docker-archive://hdv-summary.tar
```

With `-profile conda` the tools come from Conda instead. Without `test`, the reference is downloaded from NCBI.

## Parameters
| Parameter | Default | Description |
|---|---|---|
| `--in` | `data/` | Folder with the input `*.fasta` files |
| `--accession` | `M21012` | NCBI accession of the reference to download |
| `--reference` | none | Local reference FASTA; skips the download (the `test` profile sets `data/reference/M21012.fasta`) |

## Outputs
Written to `results/`:
- `cleaned_aligned.fasta`: the trimmed alignment
- `report.html`: trimAl's report of the columns it kept
- `summary.tsv`: one row per input sequence with `sequence`, `length`, `n_sequences`, `aligned_length`, `trimmed_length`, `percent_kept`

## Tests
```bash
nf-test test --profile +docker
pytest tests/test_summary.py
```
GitHub Actions runs both on every push and pull request, then runs the `test` profile once with Apptainer.
