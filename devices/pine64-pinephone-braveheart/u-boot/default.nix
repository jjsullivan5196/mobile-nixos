{ lib
, writeText
, callPackage
, buildUBoot
, armTrustedFirmwareAllwinner
, crustFirmware
, fetchpatch
, fetchFromGitLab
}:

let
  pw = id: sha256: fetchpatch {
    inherit sha256;
    name = "${id}.patch";
    url = "https://patchwork.ozlabs.org/patch/${id}/raw/";
  };
in
(buildUBoot {
  defconfig = "pinephone_defconfig";
  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
  SCP = "${crustFirmware}/scp.bin";

  extraPatches = [
    (pw "1202024" "0c196zk1s3pq3wdv909sxmjgqpll2hwb817bpbghkfkyyknl96vg")
    ./0001-HACK-Turn-red-LED-on-for-pinephone.patch
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin" "u-boot.img" "u-boot.dtb"];

  # The current u-boot build doesn't know about the USB controllers.
  # When it will, ths will allow enabling usb mass storage gadget.
  #  CONFIG_USB_MUSB_GADGET=y
  #  CONFIG_CMD_USB_MASS_STORAGE=y
  extraConfig = ''
    # The default autoboot doesn't *wait*.
    # Though any input before will cancel it.
    # This is because we re-invest the 2s in our own menu.
    CONFIG_AUTOBOOT_KEYED_CTRLC=y
    CONFIG_BOOTDELAY=0
  '';
}).overrideAttrs(old: rec {
  version = "f0b298c";
  src = fetchFromGitLab {
    owner = "pine64-org";
    repo = "u-boot";
    sha256 = "0bywbkqr13ymc54a4p8n0h4ni8p1fv79z3xvg3s3xwlvrgv2q6ni";
    rev = "f0b298c504daae9da171bac950c036432cc00201";
  };
  postInstall = ''
    cp .config $out/build.config
  '';
  postPatch = old.postPatch + ''
    cat $extraConfigPath >> configs/$defconfig
  '';
})
