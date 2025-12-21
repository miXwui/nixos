#!/usr/bin/env bash

sudo nix store gc
nix store gc

sudo nix store optimise
nix store optimise
