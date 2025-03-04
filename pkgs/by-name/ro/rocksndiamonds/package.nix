{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_net,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "rocksndiamonds";
  version = "4.4.0.0";

  src = fetchurl {
    url = "https://www.artsoft.org/RELEASES/linux/${pname}/${pname}-${version}-linux.tar.gz";
    hash = "sha256-aKHHD/v+zqxCsOYp06nqB2TShlwCwE1JaU0adO4T4Cw=";
  };

  desktopItem = makeDesktopItem {
    name = "rocksndiamonds";
    exec = "rocksndiamonds";
    icon = "rocksndiamonds";
    comment = meta.description;
    desktopName = "Rocks'n'Diamonds";
    genericName = "Tile-based puzzle";
    categories = [
      "Game"
      "LogicGame"
    ];
  };

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_net
    zlib
  ];

  preBuild = ''
    dataDir="$out/share/rocksndiamonds"
    appendToVar makeFlags "BASE_PATH=$dataDir"
  '';

  installPhase = ''
    appDir=$out/share/applications
    iconDir=$out/share/icons/hicolor/32x32/apps
    mkdir -p $out/bin $appDir $iconDir $dataDir
    cp rocksndiamonds $out/bin/
    ln -s ${desktopItem}/share/applications/* $appDir/
    ln -s $dataDir/graphics/gfx_classic/RocksIcon32x32.png $iconDir/rocksndiamonds.png
    cp -r conf docs graphics levels music sounds $dataDir
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Scrolling tile-based arcade style puzzle game";
    mainProgram = "rocksndiamonds";
    homepage = "https://www.artsoft.org/rocksndiamonds/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ orivej ];
  };
}
