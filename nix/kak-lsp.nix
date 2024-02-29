{ src
, stdenv, lib
, rustPlatform

, CoreServices, Security, SystemConfiguration
}:

rustPlatform.buildRustPackage rec {
  pname = "kak-lsp";
  version = "16.0.0";
	inherit src;

  cargoSha256 = "sha256-c7mjnvspaX9maYAzUL3pPQw9XBpduGk2TO8XjCHPV7I";

  buildInputs = lib.optionals stdenv.isDarwin [ CoreServices Security SystemConfiguration ];

  meta = with lib; {
    description = "Kakoune Language Server Protocol Client";
    homepage = "https://github.com/kak-lsp/kak-lsp";
    license = with licenses; [ unlicense /* or */ mit ];
    maintainers = [ maintainers.spacekookie ];
    mainProgram = "kak-lsp";
  };
}

