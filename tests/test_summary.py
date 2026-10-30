import subprocess
import sys
from pathlib import Path

TESTS = Path(__file__).parent
SCRIPT = TESTS.parent / "bin" / "summary.py"


def test_summary(tmp_path):
    out = tmp_path / "summary.tsv"
    data = TESTS / "data"
    subprocess.run(
        [sys.executable, SCRIPT, data / "sequences.fasta", data / "aligned.fasta", data / "trimmed.fasta", "-o", out],
        check=True,
    )
    assert out.read_text() == (data / "summary.tsv").read_text()
