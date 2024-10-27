#!/usr/bin/env bash

# Decrypt/set PIA_USER/PIA_PASS environment variables with sops.
# Then `run_setup.sh` with passed in variables.
# shellcheck disable=SC2016
sops exec-env "$XDG_NIXOS_DIR/secrets/secrets.yaml" '
    sudo VPN_PROTOCOL=wireguard \
    DISABLE_IPV6=yes \
    DIP_TOKEN=no \
    AUTOCONNECT=false \
    PIA_PF=false \
    PIA_DNS=true \
    PIA_USER=$PIA_USER \
    PIA_PASS=$PIA_PASS \
    ./run_setup.sh
'
