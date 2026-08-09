#!/usr/bin/env bash

sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
nix-collect-garbage --delete-older-than 7d
