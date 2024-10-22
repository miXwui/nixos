{ pkgs, git, ... }:
# [1] https://github.com/so-fancy/diff-so-fancy?tab=readme-ov-file#with-git
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
        pager = "diff-so-fancy | less --tabs=4 -RF"; # [1]
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

      interactive = {
        diffFilter = "diff-so-fancy --patch"; # [1]
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
