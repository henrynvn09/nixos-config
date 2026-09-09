{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "henrynvn09";
    userEmail = "henrynvn09@gmail.com";

    extraConfig = {
      core = {
        symlinks = true;
        autocrlf = "input";
      };
      diff = {
        tool = "vscode";
      };
      difftool."vscode" = {
        cmd = "code --wait --diff $LOCAL $REMOTE";
      };
      merge = {
        tool = "vscode";
      };
      mergetool."vscode" = {
        cmd = "code --wait $MERGED";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
    };
  };
}
