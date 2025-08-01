{
  enableGUI ? true,
  enablePDFtoPPM ? true,
  enablePrinting ? true,
  lib,
  stdenv,
  fetchzip,
  cmake,
  makeDesktopItem,
  zlib,
  libpng,
  cups ? null,
  freetype ? null,
  qtbase ? null,
  qtsvg ? null,
  wrapQtAppsHook,
}:

assert enableGUI -> qtbase != null && qtsvg != null && freetype != null;
assert enablePDFtoPPM -> freetype != null;
assert enablePrinting -> cups != null;

stdenv.mkDerivation rec {
  pname = "xpdf";
  version = "4.05";

  src = fetchzip {
    urls = [
      "https://dl.xpdfreader.com/xpdf-${version}.tar.gz"
      "https://dl.xpdfreader.com/old/xpdf-${version}.tar.gz"
    ];
    hash = "sha256-LBxKSrXTdoulZDjPiyYMaJr63jFHHI+VCgVJx310i/w=";
  };

  # Fix "No known features for CXX compiler", see
  # https://cmake.org/pipermail/cmake/2016-December/064733.html and the note at
  # https://cmake.org/cmake/help/v3.10/command/cmake_minimum_required.html
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace CMakeLists.txt --replace \
        'cmake_minimum_required(VERSION 2.8.12)' 'cmake_minimum_required(VERSION 3.1.0)'
  '';

  nativeBuildInputs = [ cmake ] ++ lib.optional enableGUI wrapQtAppsHook;

  cmakeFlags = [
    "-DSYSTEM_XPDFRC=/etc/xpdfrc"
    "-DA4_PAPER=ON"
    "-DOPI_SUPPORT=ON"
  ]
  ++ lib.optional (!enablePrinting) "-DXPDFWIDGET_PRINTING=OFF";

  buildInputs = [
    zlib
    libpng
  ]
  ++ lib.optional enableGUI qtbase
  ++ lib.optional enablePrinting cups
  ++ lib.optional enablePDFtoPPM freetype;

  desktopItem = makeDesktopItem {
    name = "xpdf";
    desktopName = "Xpdf";
    comment = "Views Adobe PDF files";
    icon = "xpdf";
    exec = "xpdf %f";
    categories = [ "Office" ];
  };

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    install -Dm644 ${desktopItem}/share/applications/xpdf.desktop -t $out/share/applications
    install -Dm644 $src/xpdf-qt/xpdf-icon.svg $out/share/pixmaps/xpdf.svg
  '';

  meta = with lib; {
    homepage = "https://www.xpdfreader.com";
    description = "Viewer for Portable Document Format (PDF) files";
    longDescription = ''
      XPDF includes multiple tools for viewing and processing PDF files.
        xpdf:      PDF viewer (with Graphical Interface)
        pdftotext: converts PDF to text
        pdftops:   converts PDF to PostScript
        pdftoppm:  converts PDF pages to netpbm (PPM/PGM/PBM) image files
        pdftopng:  converts PDF pages to PNG image files
        pdftohtml: converts PDF to HTML
        pdfinfo:   extracts PDF metadata
        pdfimages: extracts raw images from PDF files
        pdffonts:  lists fonts used in PDF files
        pdfdetach: extracts attached files from PDF files
    '';
    license = with licenses; [
      gpl2Only
      gpl3Only
    ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
    knownVulnerabilities = [
      "CVE-2023-26930"
      "CVE-2024-2971"
      "CVE-2024-3247"
      "CVE-2024-3248"
      "CVE-2024-3900"
      "CVE-2024-4141"
      "CVE-2024-4568"
      "CVE-2024-4976"
    ];
  };
}
