#!/usr/bin/env bash
set -euo pipefail
# Temporary public bootstrap: no secrets, no real trading.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/src"
cat >"$tmp/src/trader.py" <<'YAFES_TRADER_PY'
import json, os, urllib.request, sqlite3, datetime
from pathlib import Path

BASE = "https://api.binance.com"
DATA = Path(os.environ.get("YAFES_DATA_DIR", str(Path.home() / ".local/share/yafes-trading")))
DATA.mkdir(parents=True, exist_ok=True)
DB = DATA / "trading.sqlite3"

def api(path):
    with urllib.request.urlopen(BASE + path, timeout=20) as response:
        return json.load(response)

def run():
    info = api("/api/v3/exchangeInfo")
    eligible = {s["symbol"] for s in info["symbols"] if s["status"] == "TRADING" and s["quoteAsset"] == "USDT" and s.get("isSpotTradingAllowed", False)}
    tickers = api("/api/v3/ticker/24hr")
    candidates = sorted((t for t in tickers if t["symbol"] in eligible and float(t.get("quoteVolume", 0)) >= 10000000 and float(t.get("lastPrice", 0)) > 0), key=lambda t: float(t["quoteVolume"]), reverse=True)
    excluded = ("UPUSDT", "DOWNUSDT", "BULLUSDT", "BEARUSDT")
    candidates = [t for t in candidates if not t["symbol"].endswith(excluded) and abs(float(t["priceChangePercent"])) < 25]
    con = sqlite3.connect(DB)
    con.execute("CREATE TABLE IF NOT EXISTS scans(ts TEXT, symbol TEXT, volume_usdt REAL, change_pct REAL, score REAL, decision TEXT)")
    stamp = datetime.datetime.now(datetime.timezone.utc).isoformat()
    scored = []
    for t in candidates[:100]:
        change, vol = float(t["priceChangePercent"]), float(t["quoteVolume"])
        score = round(min(60, vol / 10000000) + max(0, 20 - abs(change - 3) * 3), 2)
        scored.append((stamp, t["symbol"], vol, change, score, "WATCH"))
    con.executemany("INSERT INTO scans VALUES(?,?,?,?,?,?)", scored)
    con.commit()
    con.close()
    print(json.dumps({"utc": stamp, "mode": "PAPER_SCAN_ONLY", "active_usdt_pairs": len(eligible), "liquid_candidates": len(candidates), "scored": len(scored), "top10": [{"symbol": s[1], "score": s[4]} for s in sorted(scored, key=lambda x: x[4], reverse=True)[:10]], "db": str(DB)}, ensure_ascii=False))

if __name__ == "__main__":
    run()

YAFES_TRADER_PY
cat >"$tmp/install.sh" <<'YAFES_INSTALL_SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$(id -u)" -ne 0 ]]; then echo "sudo bash install.sh ile çalıştır"; exit 1; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
id yafes-trading >/dev/null 2>&1 || useradd --system --create-home --shell /usr/sbin/nologin yafes-trading
install -d -m 0755 /opt/yafes-ai-trading
install -m 0644 "$SCRIPT_DIR/src/trader.py" /opt/yafes-ai-trading/trader.py
install -d -o yafes-trading -g yafes-trading -m 0700 /var/lib/yafes-ai-trading
cat >/etc/systemd/system/yafes-ai-trading.service <<'EOF'
[Unit]
Description=YAFES Binance public market scanner (paper mode)
Wants=network-online.target
After=network-online.target
[Service]
Type=oneshot
User=yafes-trading
Group=yafes-trading
Environment=YAFES_DATA_DIR=/var/lib/yafes-ai-trading
ExecStart=/usr/bin/python3 /opt/yafes-ai-trading/trader.py
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/yafes-ai-trading
PrivateTmp=yes
EOF
cat >/etc/systemd/system/yafes-ai-trading.timer <<'EOF'
[Unit]
Description=Hourly YAFES market scan
[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=0
Unit=yafes-ai-trading.service
[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now yafes-ai-trading.timer
systemctl start yafes-ai-trading.service
systemctl --no-pager --full status yafes-ai-trading.service || true
echo "Scanner kuruldu; gerçek emir gönderimi YOK."

YAFES_INSTALL_SH
bash "$tmp/install.sh"
