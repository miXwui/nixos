{ pkgs, home-manager, ... }:

{
  programs.git = {
    enable = true;
    userName = "Michael Wu";
    userEmail = "me@miXwui.com";

    extraConfig = {
      init = {
        defaultBranch = "main";
      };

      fetch = {
        prune = true;
      };

      log = {
        date = "local";
      };

      rerere = {
        enabled = true;
      };

      # TODO: Maybe use vimdiff or helix instead?
      
      core = {
        editor = "code --wait --new-window";
      };
 
      diff = {
        tool = "vscode";
      };

      difftool = {
        vscode = {
          cmd = "code --wait --diff $LOCAL $REMOTE";
        };
      };

      merge = {
        tool = "vscode";
      };

      mergetool = {
        vscode = {
          cmd = "code --wait $MERGED";
        };
      };
    };
  };
}
