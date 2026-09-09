{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "henrynvn09";
        email = "henrynvn09@gmail.com";
      };
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
