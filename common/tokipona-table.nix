{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "ibus-table-tokipona";
  version = "1";

  src = ./sitelen_pona_ibus.txt;

  dontUnpack = true;
  nativeBuildInputs = [ pkgs.ibus-engines.table ];

  buildPhase = ''
    export HOME=$TMPDIR
    ibus-table-createdb -n tokipona.db -s $src
  '';

  installPhase = ''
    mkdir -p $out/share/ibus-table/tables
    cp tokipona.db $out/share/ibus-table/tables/
  '';

  meta = {
    isIbusEngine = true;
  };
}
