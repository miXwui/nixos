{
  lib,
  pkgs,
  stdenv,
}:
stdenv.mkDerivation {
  name = "pia-manual-connections";
  src = pkgs.fetchFromGitHub {
    owner = "pia-foss";
    repo = "manual-connections";
    rev = "e956c57849a38f912e654e0357f5ae456dfd1742";
    sha256 = "sha256-otDaC45eeDbu0HCoseVOU1oxRlj6A9ChTWTSEUNtuaI=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  buildInputs = with pkgs; [
    curl
    jq
    wireguard-tools
    openvpn
  ];

  patchPhase = ''
    cp ${./connect.sh} ./connect.sh
    cp ${./disconnect.sh} ./disconnect.sh
  '';

  installPhase = ''
    mkdir -p $out
    # Copy repo's files
    cp -r $src/* $out

    # Install connect/disconnect
    install -Dm755 ./connect.sh $out/bin/pia-connect
    install -Dm755 ./disconnect.sh $out/bin/pia-disconnect

    # Change working directory before running
    wrapProgram "$out/bin/pia-connect" --chdir $out
  '';

  meta = with lib; {
    homepage = "https://github.com/pia-foss/manual-connections";
    description = "Scripts for manual connections to Private Internet Access";
    maintainers = with maintainers; [ mwu ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
