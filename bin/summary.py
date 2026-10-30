#!/usr/bin/env python3
"""Write a table with the length of each input sequence and how much of the alignment trimAl kept."""
import argparse

from Bio import AlignIO, SeqIO


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sequences", help="input sequences (FASTA)")
    parser.add_argument("aligned", help="alignment before trimming (FASTA)")
    parser.add_argument("trimmed", help="alignment after trimming (FASTA)")
    parser.add_argument("-o", "--output", default="summary.tsv")
    args = parser.parse_args()

    records = list(SeqIO.parse(args.sequences, "fasta"))
    aligned_length = AlignIO.read(args.aligned, "fasta").get_alignment_length()
    trimmed_length = AlignIO.read(args.trimmed, "fasta").get_alignment_length()
    percent_kept = 100 * trimmed_length / aligned_length

    # one row per input sequence; the alignment numbers are the same on every row
    with open(args.output, "w") as out:
        out.write("sequence\tlength\tn_sequences\taligned_length\ttrimmed_length\tpercent_kept\n")
        for record in records:
            out.write(
                f"{record.id}\t{len(record.seq)}\t{len(records)}\t"
                f"{aligned_length}\t{trimmed_length}\t{percent_kept:.1f}\n"
            )


if __name__ == "__main__":
    main()
