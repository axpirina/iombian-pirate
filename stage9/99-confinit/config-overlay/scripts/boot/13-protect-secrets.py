#!/usr/bin/env python3
"""Hash Wi-Fi passphrases after Confinit renders the configuration."""

from pathlib import Path
import json
import re
import subprocess

PARAMETERS = Path("/boot/firmware/config/parameters.yml")
WPA_CONFIG = Path("/etc/wpa_supplicant/wpa_supplicant.conf")
HEX_PSK = re.compile(r"^[0-9a-fA-F]{64}$")


def yaml_string(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def parse_scalar(raw_value: str) -> str:
    raw_value = raw_value.strip()
    if raw_value.startswith("'") and raw_value.endswith("'"):
        return raw_value[1:-1].replace("''", "'")
    if raw_value.startswith('"') and raw_value.endswith('"'):
        return json.loads(raw_value)
    return raw_value


def hash_parameter_psks() -> None:
    if not PARAMETERS.is_file():
        return

    output = []
    changed = False
    current_ssid = None

    for line in PARAMETERS.read_text().splitlines(keepends=True):
        ssid_match = re.match(r"^(\s*)ssid:\s*(.*)$", line)
        if ssid_match:
            current_ssid = parse_scalar(ssid_match.group(2))
            output.append(line)
            continue

        psk_match = re.match(r"^(\s*)psk:(\s*)(.*)$", line)
        if not psk_match or not current_ssid:
            output.append(line)
            continue

        indent, spacing, raw_psk = psk_match.groups()
        psk = parse_scalar(raw_psk)

        if psk and not HEX_PSK.fullmatch(psk):
            result = subprocess.run(
                ["wpa_passphrase", current_ssid, psk],
                check=True,
                capture_output=True,
                text=True,
            )
            match = re.search(r"^\s+psk=([0-9a-f]{64})$", result.stdout, re.MULTILINE)
            if not match:
                raise RuntimeError(f"Could not hash the Wi-Fi passphrase for {current_ssid}")
            ending = "\n" if line.endswith("\n") else ""
            line = f"{indent}psk:{spacing}{yaml_string(match.group(1))}{ending}"
            changed = True

        output.append(line)

    if changed:
        temporary = PARAMETERS.with_suffix(".yml.tmp")
        temporary.write_text("".join(output))
        temporary.chmod(0o600)
        temporary.replace(PARAMETERS)


def hash_rendered_psks() -> None:
    if not WPA_CONFIG.is_file():
        return

    content = WPA_CONFIG.read_text()

    def replace_network(match: re.Match) -> str:
        block = match.group(0)
        ssid_match = re.search(r'^\s*ssid="([^"]*)"$', block, re.MULTILINE)
        psk_match = re.search(r'^(\s*)psk="([^"]*)"$', block, re.MULTILINE)
        if not ssid_match or not psk_match:
            return block

        ssid = ssid_match.group(1)
        psk = psk_match.group(2)
        if not psk or HEX_PSK.fullmatch(psk):
            return block

        result = subprocess.run(
            ["wpa_passphrase", ssid, psk],
            check=True,
            capture_output=True,
            text=True,
        )
        hashed = re.search(r"^\s+psk=([0-9a-f]{64})$", result.stdout, re.MULTILINE)
        if not hashed:
            raise RuntimeError(f"Could not hash the rendered Wi-Fi passphrase for {ssid}")
        replacement = f"{psk_match.group(1)}psk={hashed.group(1)}"
        return block[:psk_match.start()] + replacement + block[psk_match.end():]

    content = re.sub(r"^network=\{\n.*?^\}", replace_network, content, flags=re.MULTILINE | re.DOTALL)
    WPA_CONFIG.write_text(content)
    WPA_CONFIG.chmod(0o600)


hash_rendered_psks()
hash_parameter_psks()
