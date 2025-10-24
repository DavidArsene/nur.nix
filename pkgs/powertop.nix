{
  fetchFromGitHub,
  powertop,
  libtracefs,
  libtraceevent,
}:
powertop.overrideAttrs (prev: {

  # Latest version, that supports --auto-tune-dump
  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    rev = "49045c0"; # latest as of july 2025
    hash = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    libtracefs
    libtraceevent
  ];
})
