import subprocess


def notify(*args: list[str]) -> str:
    return subprocess.check_output(["notify-send", "-a", "shellscape-cli", *args], text=True).strip()
