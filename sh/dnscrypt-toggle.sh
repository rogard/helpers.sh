#!/usr/bin/env bash
#===============================================================================
#  dnscrypt-toggle.sh — Toggle DNS resolution through dnscrypt-proxy
#
#  Author: Erwann Rogard
#  License: GPL 3.0 (https://www.gnu.org/licenses/gpl-3.0.en.html)
#
#  Config:
#    Customize variables below
#
#  Usage:
#    ./dnscrypt-toggle.sh --enable
#    ./dnscrypt-toggle.sh --disable
#===============================================================================

# --- CONFIGURABLE VARIABLES --------------------------------------------------
localhost_ip='127.0.0.1'
dns_port='53'
conn_name="ATTh3ecQs2"
dnscrypt_conf="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
# -----------------------------------------------------------------------------

# --- DERIVED CHECK PATTERN ---------------------------------------------------
escaped_ip=${localhost_ip//./\\.}
pattern="^listen_addresses = \['${escaped_ip}:${dns_port}'\]"
# -----------------------------------------------------------------------------

if (( EUID == 0 )); then
  echo "❌ Script is being run with sudo."
  exit 1
fi

check_dnscrypt_binary() {
    if ! command -v dnscrypt-proxy &>/dev/null; then
        echo "❌ error: dnscrypt-proxy binary not found in PATH"
        exit 1
    fi
}

check_config() {
    if ! grep -v '^\s*#' "$dnscrypt_conf" | grep -q "$pattern"; then
        echo "❌ error: required setting \`$pattern\` not found in $dnscrypt_conf"
        exit 1
    fi
}

check_connection_active() {
    if ! nmcli -t -f NAME,DEVICE connection show --active | grep -q "^$conn_name:"; then
        echo "❌ error: Connection '$conn_name' is not active."
        exit 1
    fi
}

modify_dns_settings() {
    local enable=$1
    if (( enable )); then
        sudo nmcli connection modify "$conn_name" ipv4.dns "$localhost_ip"
        sudo nmcli connection modify "$conn_name" ipv4.ignore-auto-dns yes
    else
        sudo nmcli connection modify "$conn_name" ipv4.ignore-auto-dns no
        sudo nmcli connection modify "$conn_name" ipv4.dns ""
    fi
}

apply_connection_changes() {
    echo "🔄 Applying network changes to '$conn_name'..."
    device=$(nmcli -t -f DEVICE,STATE device | grep ':connected' | cut -d: -f1 | head -n1)
    if [[ -n "$device" ]]; then
        sudo nmcli device reapply "$device" || {
            echo "⚠️ Failed to reapply connection; falling back to reload."
            sudo nmcli connection reload "$conn_name"
        }
    else
        echo "⚠️ Could not detect active device. Reloading connection config."
        sudo nmcli connection reload "$conn_name"
    fi
}

enable_dnscrypt() {
    check_dnscrypt_binary
    check_config
    check_connection_active

    echo "🔧 Enabling dnscrypt-proxy..."

    sudo systemctl enable dnscrypt-proxy || { echo "❌ Failed to enable dnscrypt-proxy"; exit 1; }
    sudo systemctl start dnscrypt-proxy  || { echo "❌ Failed to start dnscrypt-proxy"; exit 1; }

    modify_dns_settings 1
    apply_connection_changes

    echo "✅ DNSCrypt-proxy is now active on '$conn_name'"
}

disable_dnscrypt() {
    echo "🔧 Disabling dnscrypt-proxy..."

    sudo systemctl stop dnscrypt-proxy
    sudo systemctl disable dnscrypt-proxy

    modify_dns_settings 0
    apply_connection_changes

    echo "↩️ Reverted DNS settings on '$conn_name'"
}

run_checks() {
    echo "💡 Running post-enable checks..."

    echo -n "🔍 Checking listening UDP ports on :53... "
    if sudo ss -lunp | grep -q ':53'; then
        sudo ss -lunp | grep ':53'
    else
        echo "No service listening on port 53 found."
    fi

    echo
    echo "🔍 Testing DNS resolution through dnscrypt-proxy..."
    if dnscrypt-proxy -config "$dnscrypt_conf" -resolve example.com; then
        echo "✅ DNS resolution succeeded."
    else
        echo "❌ DNS resolution failed"
    fi

    echo
    echo "🌐 Opening DNS leak test in your default browser..."
    xdg-open "https://www.dnsleaktest.com" >/dev/null 2>&1 &
}

# --- ENTRYPOINT --------------------------------------------------------------
case $1 in
    --enable)
        enable_dnscrypt
        run_checks
        ;;
    --disable)
        disable_dnscrypt
        ;;
    *)
        echo "Usage: $0 --enable | --disable"
        exit 1
        ;;
esac
