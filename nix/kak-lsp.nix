{ src
, stdenv, lib
, rustPlatform

, CoreServices, Security, SystemConfiguration
}:

rustPlatform.buildRustPackage rec {
  pname = "kak-lsp";
  version = "14.2.0";
	inherit src;

  cargoSha256 = "sha256-qLeZ896aPfuQWbm4Y15suiPqT3agk379k413fWz3adg=";

  buildInputs = lib.optionals stdenv.isDarwin [ CoreServices Security SystemConfiguration ];

  meta = with lib; {
    description = "Kakoune Language Server Protocol Client";
    homepage = "https://github.com/kak-lsp/kak-lsp";
    license = with licenses; [ unlicense /* or */ mit ];
    maintainers = [ maintainers.spacekookie ];
    mainProgram = "kak-lsp";
  };
}

