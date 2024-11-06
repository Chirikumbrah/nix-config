{ config, pkgs, ... }:
{
    home = {
        username = "yr";
        homeDirectory = "/Users/yr";
        stateVersion = "24.05";
        sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "$EDITOR";
            PAGER = "less";
            CLICOLOR = 1;
            XDG_CONFIG_HOME = "$HOME/.config";
            PATH = "$PATH:$HOME/.local/bin:$HOME/.config/scripts:$HOME/.cargo/bin:/Applications/Postgres.app/Contents/Versions/latest/bin:/Library/Frameworks/Python.framework/Versions/3.12/bin:$HOME/.orbstack/bin";
        };
    };
    programs = {
        home-manager.enable = true;
        bash = {
            enableCompletion = true;
            shellAliases = {
                l = "ls --color=auto";
                ll = "ls -halF";
                ls = "ls -h --color=auto";
                grep = "grep --color=auto";
                fgrep = "fgrep --color=auto";
                egrep = "egrep --color=auto";
            };
            historySize = 50000;
            historyIgnore = [ "&" "ls" "[bf]g" "eb" "gp" "z" "v" "dot" "exit" "history" ];
            historyControl = [ "ignoreboth" "erasedups" ];
            historyFileSize = 10000;
            shellOptions = [
                "histappend"
                "checkwinsize"
                "extglob"
                "globstar"
                "dotglob"
                "checkjobs"
            ];
            sessionVariables = {
                BASH_SILENCE_DEPRECATION_WARNING = 1;
                SAVEHIST = 50000;
            };
        };
    };
}
