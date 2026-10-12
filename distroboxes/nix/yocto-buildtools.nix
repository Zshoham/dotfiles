# The yocto buildtools-extended SDK, the nix equivalent of yocto.sh and the
# yocto part of init.sh. Installed with the upstream installer, which
# relocates the SDK into the store path.
{
  lib,
  stdenvNoCC,
  fetchurl,
  file,
  python3,
  which,
  xz,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yocto-buildtools-extended";
  version = "4.3.4";

  src = fetchurl {
    url = "https://downloads.yoctoproject.org/releases/yocto/yocto-${finalAttrs.version}/buildtools/x86_64-buildtools-extended-nativesdk-standalone-${finalAttrs.version}.sh";
    # TODO: real hash, the download is blocked where this was written
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [
    file
    python3
    which
    xz
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    sh $src -y -d $out

    # Use the system certificates instead of the ones shipped with the SDK.
    sed -i '/ssl/d' $out/environment-setup-x86_64-pokysdk-linux

    runHook postInstall
  '';

  # The SDK ships its own loader and libraries, leave its binaries alone.
  dontFixup = true;

  meta = {
    description = "Yocto Project buildtools-extended SDK";
    homepage = "https://docs.yoctoproject.org/ref-manual/system-requirements.html#downloading-a-pre-built-buildtools-tarball";
    platforms = [ "x86_64-linux" ];
  };
})
