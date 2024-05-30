{ pkgs, home-manager, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      #function nvm
        #bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
      #end

      #set -x NVM_DIR ~/.nvm
      #nvm use default --silent

      ## Enable history in IEX
      #export ERL_AFLAGS="-kernel shell_history enabled"

      ## asdf Fish & Git
      ## https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
      #source ~/.asdf/asdf.fish

      ## https://major.io/p/use-gnome-keyring-with-sway/
      #export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
   '';
    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      #{ name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      #{ name = "forgit"; src = pkgs.fishPlugins.forgit.src; }
      #{ name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      #{ name = "grc"; src = pkgs.fishPlugins.grc.src; }
    ];
    shellAbbrs = {
      # Misc
      ytdl = "~/Documents/scripts/download-yt-mix.sh";

      # Git
      gca = "git commit --amend";
      grc = "git rebase --continue";
      gcm = "git checkout main";
      gcs = "git checkout staging";
      gcb = "git checkout -b mwu/";
      gbd = "git branch -d mwu/";
      gpb = "git push -u origin mwu/";
      gri = "git rebase -i HEAD~";
      gap = "git add -p";
      gsu = "git stash -u";
      gwhoami = "echo \"user.name:\" (git config user.name) && echo \"user.email:\" (git config user.email)";
      ggrep = "git log -i --grep=\"\"";
      grl = "git rev-list --count HEAD ^branch";
    };
  };
}
