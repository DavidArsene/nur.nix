{
  fetchFromGitHub,
  powertop,
  libtracefs,
  libtraceevent,
}:
powertop.overrideAttrs (prev: {

  # Latest version, with support for --auto-tune-dump
  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    rev = "49045c0"; # latest as of march 2026
    hash = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    libtracefs
    libtraceevent
  ];
})
