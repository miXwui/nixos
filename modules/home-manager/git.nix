{ pkgs, git, ... }:

{
  _module.args = {
    git = pkgs.git;
  };

  home.packages = with pkgs; [
    bfg-repo-cleaner
  ];

  programs.git = {
    enable = true;
    package = git;

    userName = "Michael Wu";
    userEmail = "me@miXwui.com";

    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

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

      core = {
        editor = "hx";
      };

      diff = {
        # TODO: Maybe use vimdiff or helix instead?
        tool = "vscode";
        wsErrorHighlight = "all";
      };

      difftool = {
        vscode = {
          # TODO: Maybe use vimdiff or helix instead?
          cmd = "code --wait --diff $LOCAL $REMOTE";
        };
      };

      merge = {
        # TODO: Maybe use vimdiff or helix instead?
        tool = "vscode";
      };

      mergetool = {
        # TODO: Maybe use vimdiff or helix instead?
        vscode = {
          cmd = "code --wait $MERGED";
        };
      };
    };
  };
}
