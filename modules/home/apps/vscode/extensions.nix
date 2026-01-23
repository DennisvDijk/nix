{ pkgs, ...}:

with pkgs.vscode-extensions; [
  eamodio.gitlens
  esbenp.prettier-vscode
  usernamehw.errorlens
  pkief.material-icon-theme
  jnoortheen.nix-ide
  ms-python.python
  ms-azuretools.vscode-docker
  donjayamanne.githistory
  ms-vscode.cpptools
  ms-kubernetes-tools.vscode-kubernetes-tools
]


