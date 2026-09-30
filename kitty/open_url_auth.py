from urllib.parse import urlparse


def is_cmd_allowed(pcmd, window, from_socket, extra_data):
    if pcmd.get("cmd") != "run":
        return False

    payload = pcmd.get("payload") or {}
    cmdline = payload.get("cmdline")

    if not isinstance(cmdline, list) or len(cmdline) != 2:
        return False

    program, url = cmdline

    if program != "xdg-open":
        return False

    try:
        parsed = urlparse(url)
    except Exception:
        return False

    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)
