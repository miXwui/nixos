{ pkgs, git, ... }:
# [1] https://github.com/so-fancy/diff-so-fancy?tab=readme-ov-file#with-git
# [2] https://github.com/dandavison/delta?tab=readme-ov-file#get-started
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
        # pager = "diff-so-fancy | less --tabs=4 -RF"; # [1]
        pager = "delta"; # [2]
      };

      interactive = {
        # diffFilter = "diff-so-fancy --patch"; # [1]
        diffFilter = "delta --color-only"; # [2]
      };

      #[2]
      delta = {
        navigate = true; # use n and N to move between diff sections

        # delta detects terminal colors automatically; set one of these to disable auto-detection
        # dark = true
        # light = true
      };

      diff = {
        # TODO: Maybe use vimdiff or helix instead?
        tool = "vscode";
        wsErrorHighlight = "all";
        colorMoved = "default"; # [2]
      };

      difftool = {
        vscode = {
          # TODO: Maybe use vimdiff or helix instead?
          cmd = "code --wait --diff $LOCAL $REMOTE";
        };
      };

      merge = {
        conflictstyle = "diff3"; # [2]
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
