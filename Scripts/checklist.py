import re
from pathlib import Path

def analyze_checklist(filename: str, /) -> None:
    file_path = Path(filename)

    if not file_path.exists():
        print(f"Error: File {filename!r} not found.")
        return

    completed: int = 0
    remaining: int = 0

    checked_pattern = re.compile(r'^\s*-\s*\[x\]', re.IGNORECASE)
    unchecked_pattern = re.compile(r'^\s*-\s*\[\s\]')

    data = file_path.read_text()
    for line in data.splitlines():
        if checked_pattern.match(line):
            completed += 1
        elif unchecked_pattern.match(line):
            remaining += 1

    total = completed + remaining
    print(f"total items: {total}")
    print(f"completed items: {completed}")
    print(f"remaining items: {remaining}")

if __name__ == "__main__":
    analyze_checklist("CHECKLIST.md")
