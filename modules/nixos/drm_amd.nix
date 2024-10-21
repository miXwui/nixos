{ pkgs, ... }:

let
  amd_drm = pkgs.callPackage ../../packages/drm_amd.nix { };
in
{
  # Needed for amd_s2idle.py
  boot.kernelModules = [ "msr" ];
  # amd_s2idle, get_amdgpu_fw_version, psr
  environment.systemPackages = [ amd_drm ];
}
