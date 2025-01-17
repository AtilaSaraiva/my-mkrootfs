{ pkgs, lib, mesa-git-src, ... }:
{
  nixpkgs.overlays =
    let
      galliumDrivers = [ "swrast" "radeonsi" "zink" "virgl" "svga" ];
      vulkanDrivers = [ "swrast" "amd" "virtio-experimental" ];

      thisConfigsOverlay = final: prev: {

        # Latest mesa with more drivers
        mesa-bleeding = (final.callPackage ../pkgs/mesa {
          llvmPackages = final.llvmPackages_latest;
          inherit (final.darwin.apple_sdk.frameworks) OpenGL;
          inherit (final.darwin.apple_sdk.libs) Xplugin;
          inherit galliumDrivers vulkanDrivers;
          inherit mesa-git-src;
          libclc = final.libclc_14;
          enableRust = false;
        });
        lib32-mesa-bleeding = (final.pkgsi686Linux.callPackage ../pkgs/mesa {
          llvmPackages = final.pkgsi686Linux.llvmPackages_latest;
          inherit (final.pkgsi686Linux.darwin.apple_sdk.frameworks) OpenGL;
          inherit (final.pkgsi686Linux.darwin.apple_sdk.libs) Xplugin;
          inherit galliumDrivers vulkanDrivers;
          inherit mesa-git-src;
          libclc = final.libclc_14;
          enableRust = false;
        });

        libclc_14 = (final.callPackage ../pkgs/libclc {
          llvmPackages = final.llvmPackages_latest;
          spirv-llvm-translator = final.spirv-llvm-translator_14;
        });
      };
    in
    [ thisConfigsOverlay ];

  # Apply latest mesa in the system
  hardware.opengl.package = pkgs.mesa-bleeding.drivers;
  hardware.opengl.package32 = pkgs.lib32-mesa-bleeding.drivers;
  hardware.opengl.extraPackages = [ pkgs.mesa-bleeding.opencl ];

  # Creates a second boot entry without latest drivers
  specialisation.stable-mesa.configuration = {
    system.nixos.tags = [ "stable-mesa" ];
    hardware.opengl.package = lib.mkForce pkgs.mesa.drivers;
    hardware.opengl.package32 = lib.mkForce pkgs.pkgsi686Linux.mesa.drivers;
  };
}
