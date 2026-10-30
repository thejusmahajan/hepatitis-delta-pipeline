nextflow.enable.dsl=2
//download fasta from ncbi using accession number
process DOWNLOAD_REFERENCE {
    conda 'entrez-direct=24.0'
    container 'quay.io/biocontainers/entrez-direct:24.0--he881be0_0'
    input:
    val accession

    output:
    path "${accession}.fasta"

    script:
    """
    esearch -db nucleotide -query "${accession}" | efetch -format fasta > "${accession}.fasta"
    """
}
// combinig process. 
process COMBINE {
    container 'ubuntu:noble-20261024.1'
    input:
    path fastas

    output:
    path "combined.fasta"
// Concatenate the input FASTA files and the reference into one file.
    script:
    """
    cat $fastas > combined.fasta
    """
}
// alignment
process ALIGN {
    conda 'mafft=7.525'
    container 'quay.io/biocontainers/mafft:7.525--h031d066_1'
    input:
    path combined_fasta

    output:
    path "aligned.fasta"
// Align all sequences with MAFFT's default progressive method (FFT-NS-2).
    script:
    """
    mafft $combined_fasta > aligned.fasta
    """
}
// again, trimal tool is something that need care
// Remove poorly aligned columns with trimAl's -automated1 heuristic and write an HTML report.
process TRIMAL {
    conda 'trimal=1.5.0'
    container 'quay.io/biocontainers/trimal:1.5.0--h9948957_2'
    input:
    path aligned_fasta

    output:
    path "cleaned_aligned.fasta", emit: trimmed
    path "report.html", emit: report

    script:
    """
    trimal -in $aligned_fasta -out cleaned_aligned.fasta -htmlout report.html -automated1
    """
}
// sequence lengths and how much of the alignment was kept
process SUMMARY {
    conda 'biopython=1.88'
    container 'hdv-summary:0.1.0'
    input:
    path combined_fasta
    path aligned_fasta
    path cleaned_fasta

    output:
    path "summary.tsv", emit: summary

    script:
    """
    summary.py $combined_fasta $aligned_fasta $cleaned_fasta -o summary.tsv
    """
}

workflow {
    if (params.in) {
        input_ch = Channel.fromPath("${params.in}/*.fasta")
                          .ifEmpty { error "No fasta files found in ${params.in}" }
        
        // Use the given reference file, otherwise download it
        if (params.reference) {
            ref_ch = Channel.fromPath(params.reference, checkIfExists: true)
        } else {
            ref_ch = DOWNLOAD_REFERENCE(params.accession)
        }

        // Mix and collect
        all_fastas = input_ch.mix(ref_ch).collect()
        
        combine_out = COMBINE(all_fastas)
        align_out = ALIGN(combine_out)
        trimal_out = TRIMAL(align_out)
        SUMMARY(combine_out, align_out, trimal_out.trimmed)
    } else {
        error "--in directory is missing"
    }
}
