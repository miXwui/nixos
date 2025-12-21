# https://wiki.nixos.org/wiki/Virt-manager
# TODO: may require more setup from the above link, though it works well
# currently with a Fedora VM.
{ ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
