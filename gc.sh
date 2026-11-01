#!/usr/bin/env bash

echo "Deleting old system generations..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
echo "Collecting garbage"
nix-collect-garbage --delete-older-than 7d
echo "Running nix-store --optimise (this may take a while)"
time nix-store --optimise
