#!/bin/bash
#
# lazyman - install, initialize, manage, and explore multiple Neovim configurations
#
# Written by Ronald Record <ronaldrecord@gmail.com>
#
# shellcheck disable=SC2001,SC2002,SC2016,SC2006,SC2086,SC2181,SC2129,SC2059,SC2076

LAZYMAN="nvim-Lazyman"
LMANDIR="${HOME}/.config/${LAZYMAN}"
NVIMDIRS="${LMANDIR}/.nvimdirs"
LOLCAT="lolcat --animate --speed=70.0"
BOLD=$(tput bold 2>/dev/null)
NORM=$(tput sgr0 2>/dev/null)
PLEASE="Please enter your"
FIG_TEXT="Lazyman"
USEGUI=
BASECFGS="AstroNvim Ecovim LazyVim LunarVim NvChad SpaceVim MagicVim"
EXTRACFGS="Nv Abstract Allaman Fennel NvPak Optixal Plug Heiker"
STARTCFGS="Kickstart starter-Minimal starter-StartBase starter-Opinion \
           starter-Lsp starter-Mason starter-Modular"
# Array with font names
fonts=("sblood" "lean" "sblood" "slant" "shadow" "speed" "small" "script" "standard")

brief_usage() {
  printf "\nUsage: lazyman [-A] [-a] [-b branch] [-c] [-d] [-e] [-E config]"
  printf "\n       [-i] [-k] [-l] [-m] [-s] [-S] [-v] [-n] [-p] [-P] [-q]"
  printf "\n       [-I] [-L cmd] [-rR] [-C url] [-D subdir] [-N nvimdir]"
  printf "\n       [-U] [-w conf] [-W] [-x conf] [-X] [-y] [-z] [-Z] [-u]"
  [ "$1" == "noexit" ] || exit 1
}

usage() {
  brief_usage noexit
  printf "\nWhere:"
  printf "\n    -A indicates install all supported Neovim configurations"
  printf "\n    -a indicates install and initialize AstroNvim Neovim configuration"
  printf "\n    -b 'branch' specifies an ${LAZYMAN} git branch to checkout"
  printf "\n    -c indicates install and initialize NvChad Neovim configuration"
  printf "\n    -d indicates debug mode"
  printf "\n    -e indicates install and initialize Ecovim Neovim configuration"
  printf "\n    -E 'config' execute 'nvim' with 'config' Neovim configuration"
  printf "\n       'config' can be one of:"
  printf "\n           'lazyman', 'astronvim', 'kickstart', 'magicvim',"
  printf "\n           'ecovim', 'nvchad', 'lazyvim', 'lunarvim', 'spacevim'"
  printf "\n       or any Neovim configuration directory in '~/.config'"
  printf "\n           (e.g. 'lazyman -E lazyvim foo.lua')"
  printf "\n    -i indicates install and initialize Lazyman Neovim configuration"
  printf "\n    -k indicates install and initialize Kickstart Neovim configuration"
  printf "\n    -l indicates install and initialize LazyVim Neovim configuration"
  printf "\n    -m indicates install and initialize MagicVim Neovim configuration"
  printf "\n    -s indicates install and initialize SpaceVim Neovim configuration"
  printf "\n    -v indicates install and initialize LunarVim Neovim configuration"
  printf "\n    -S indicates show Neovim configuration fuzzy selector menu"
  printf "\n    -n indicates dry run, don't actually do anything, just printf's"
  printf "\n    -p indicates use vim-plug rather than Lazy to initialize"
  printf "\n    -P indicates use Packer rather than Lazy to initialize"
  printf "\n    -q indicates quiet install"
  printf "\n    -I indicates install language servers and tools for coding diagnostics"
  printf "\n    -L 'cmd' specifies a Lazy command to run in the selected configuration"
  printf "\n    -r indicates remove the previously installed configuration"
  printf "\n    -R indicates remove previously installed configuration and backups"
  printf "\n    -C 'url' specifies a URL to a Neovim configuration git repository"
  printf "\n    -N 'nvimdir' specifies the folder name to use for the config given by -C"
  printf "\n    -U indicates update an existing configuration"
  printf "\n    -w 'conf' indicates install and initialize Extra 'conf' config"
  printf "\n       'conf' can be one of:"
  printf "\n           'Abstract', 'Allaman', 'Fennel', 'Nv', 'NvPak',"
  printf "\n           'Optixal', 'Plug', or 'Heiker'"
  printf "\n    -W indicates install and initialize all 'Extra' Neovim configurations"
  printf "\n    -x 'conf' indicates install and initialize nvim-starter 'conf' config"
  printf "\n       'conf' can be one of:"
  printf "\n           'Minimal', 'StartBase', 'Opinion', 'Lsp', 'Mason', or 'Modular'"
  printf "\n    -X indicates install and initialize all nvim-starter configs"
  printf "\n    -y indicates do not prompt, answer 'yes' to any prompt"
  printf "\n    -z indicates do not run nvim after initialization"
  printf "\n    -Z indicates do not install Homebrew, Neovim, or any other tools"
  printf "\n    -u displays this usage message and exits"
  printf "\nCommands act on NVIM_APPNAME, override with '-N nvimdir' or '-A'"
  printf "\nWithout arguments lazyman installs and initializes ${LAZYMAN}"
  printf "\nor, if initialized, an interactive menu system is displayed.\n"
  exit 1
}

create_backups() {
  ndir="$1"
  [ -d "${HOME}/.config/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nBacking up existing ${ndir} config as ${HOME}/.config/${ndir}-bak$$"
    }
    [ "$tellme" ] || {
      mv "${HOME}/.config/$ndir" "${HOME}/.config/$ndir-bak$$"
    }
  }

  [ -d "${HOME}/.local/share/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nBacking up existing ${ndir} plugins as ${HOME}/.local/share/${ndir}-bak$$"
    }
    [ "$tellme" ] || {
      mv "${HOME}/.local/share/$ndir" "${HOME}/.local/share/$ndir-bak$$"
    }
  }

  [ -d "${HOME}/.local/state/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nBacking up existing ${ndir} state as ${HOME}/.local/state/${ndir}-bak$$"
    }
    [ "$tellme" ] || {
      mv "${HOME}/.local/state/$ndir" "${HOME}/.local/state/$ndir-bak$$"
    }
  }
  [ -d "${HOME}/.cache/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nBacking up existing ${ndir} cache as ${HOME}/.cache/${ndir}-bak$$"
    }
    [ "$tellme" ] || {
      mv "${HOME}/.cache/$ndir" "${HOME}/.cache/$ndir-bak$$"
    }
  }
}

run_command() {
  neodir="$1"
  comm="$2"
  [ "$neodir" == "$lazymandir" ] && {
    oldpack=${packer}
    oldplug=${plug}
    plug=
    packer=
  }
  [ "$neodir" == "$magicvimdir" ] && {
    oldpack=${packer}
    packer=1
  }
  [ "$tellme" ] || {
    export NVIM_APPNAME="$neodir"
    if [ "$debug" ]; then
      if [ "$packer" ]; then
        nvim --headless -c 'autocmd User PackerComplete quitall' -c "Packer${comm}"
      else
        if [ "$plug" ]; then
          nvim --headless -c 'set nomore' -c "Plug${comm}" -c 'qa'
        else
          if [ "$neodir" == "$spacevimdir" ]; then
            nvim --headless "+${comm}" +qa
          else
            nvim --headless "+Lazy! ${comm}" +qa
          fi
        fi
      fi
    else
      if [ "$packer" ]; then
        nvim --headless -c \
          'autocmd User PackerComplete quitall' -c "Packer${comm}" >/dev/null 2>&1
      else
        if [ "$plug" ]; then
          nvim --headless -c 'set nomore' -c "Plug${comm}" -c 'qa' >/dev/null 2>&1
        else
          if [ "$neodir" == "$spacevimdir" ]; then
            nvim --headless "+${comm}" +qa >/dev/null 2>&1
          else
            nvim --headless "+Lazy! ${comm}" +qa >/dev/null 2>&1
          fi
        fi
      fi
    fi
  }
  [ "$neodir" == "$magicvimdir" ] && packer=${oldpack}
  [ "$neodir" == "$lazymandir" ] && {
    packer=${oldpack}
    plug=${oldplug}
  }
}

init_neovim() {
  neodir="$1"
  [ "$neodir" == "$lazymandir" ] && {
    oldpack=${packer}
    oldplug=${plug}
    plug=
    packer=
  }
  [ "$neodir" == "$magicvimdir" ] && {
    oldpack=${packer}
    packer=1
  }
  export NVIM_APPNAME="$neodir"

  [ "$packer" ] && {
    PACKER="${HOME}/.local/share/${neodir}/site/pack/packer/start/packer.nvim"
    [ -d "$PACKER" ] || {
      [ "$quiet" ] || {
        printf "\nCloning packer.nvim into"
        printf "\n\t${PACKER} ... "
      }
      [ "$tellme" ] || {
        git clone --depth 1 \
          https://github.com/wbthomason/packer.nvim "$PACKER" >/dev/null 2>&1
      }
      [ "$quiet" ] || printf "done"
    }
  }

  [ "$plug" ] && {
    PLUG="${HOME}/.local/share/${neodir}/site/autoload/plug.vim"
    [ -d "$PLUG" ] || {
      [ "$quiet" ] || {
        printf "\nCopying plug.vim to"
        printf "\n\t${PLUG} ... "
      }
      [ "$tellme" ] || {
        sh -c "curl -fLo ${PLUG} --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" \
          >/dev/null 2>&1
      }
      [ "$quiet" ] || printf "done"
    }
  }

  if [ "$debug" ]; then
    if [ "$packer" ]; then
      nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    else
      if [ "$plug" ]; then
        nvim --headless -c 'set nomore' -c 'PlugInstall' -c 'qa'
        nvim --headless -c 'set nomore' -c 'UpdateRemotePlugins' -c 'qa'
        nvim --headless -c 'set nomore' -c 'GoInstallBinaries' -c 'qa'
      else
        if [ "$neodir" == "$spacevimdir" ]; then
          nvim --headless "+SPInstall" +qa
          nvim --headless "+UpdateRemotePlugins" +qa
        else
          nvim --headless "+Lazy! sync" +qa
        fi
      fi
    fi
    [ -d "${HOME}/.config/${neodir}/doc" ] && {
      nvim --headless "+helptags ${HOME}/.config/${neodir}/doc" +qa
    }
  else
    if [ "$packer" ]; then
      nvim --headless -c \
        'autocmd User PackerComplete quitall' -c 'PackerSync' >/dev/null 2>&1
    else
      if [ "$plug" ]; then
        nvim --headless -c 'set nomore' -c 'PlugInstall' -c 'qa' >/dev/null 2>&1
        nvim --headless -c 'set nomore' -c 'UpdateRemotePlugins' -c 'qa' >/dev/null 2>&1
        nvim --headless -c 'set nomore' -c 'GoInstallBinaries' -c 'qa' >/dev/null 2>&1
      else
        if [ "$neodir" == "$spacevimdir" ]; then
          nvim --headless "+SPInstall" +qa >/dev/null 2>&1
          nvim --headless "+UpdateRemotePlugins" +qa >/dev/null 2>&1
        else
          nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1
        fi
      fi
    fi
    [ -d "${HOME}/.config/${neodir}/doc" ] && {
      nvim --headless "+helptags ${HOME}/.config/${neodir}/doc" +qa >/dev/null 2>&1
    }
  fi
  [ "$neodir" == "$magicvimdir" ] && packer=${oldpack}
  [ "$neodir" == "$lazymandir" ] && {
    packer=${oldpack}
    plug=${oldplug}
  }
}

add_nvimdirs_entry() {
  ndir="$1"
  if [ -f "${NVIMDIRS}" ]; then
    grep ^"$ndir"$ "${NVIMDIRS}" >/dev/null || {
      echo "$ndir" >>"${NVIMDIRS}"
    }
  else
    [ -d "${LMANDIR}" ] && {
      echo "$ndir" >"${NVIMDIRS}"
    }
  fi
}

remove_nvimdirs_entry() {
  ndir="$1"
  [ -f "${NVIMDIRS}" ] && {
    grep ^"$ndir"$ "${NVIMDIRS}" >/dev/null && {
      grep -v ^"$ndir"$ "${NVIMDIRS}" >/tmp/nvimdirs$$
      cp /tmp/nvimdirs$$ "${NVIMDIRS}"
      rm -f /tmp/nvimdirs$$
    }
  }
}

remove_config() {
  ndir="$1"
  [ "$proceed" ] || {
    printf "\nYou have requested removal of the Neovim configuration at:"
    printf "\n\t${HOME}/.config/${ndir}\n"
    printf "\nConfirm removal of the Neovim ${ndir} configuration\n"
    while true; do
      read -r -p "Remove ${ndir} ? (y/n) " yn
      case $yn in
        [Yy]*)
          break
          ;;
        [Nn]*)
          printf "\nAborting removal and exiting\n"
          exit 0
          ;;
        *)
          printf "\nPlease answer yes or no.\n"
          ;;
      esac
    done
  }

  [ -d "${HOME}/.config/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving existing ${ndir} config at ${HOME}/.config/${ndir}"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.config/$ndir"
    }
  }
  [ "$removeall" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving any ${ndir} config backups"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.config/$ndir"-bak*
    }
  }

  [ -d "${HOME}/.local/share/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving existing ${ndir} plugins at ${HOME}/.local/share/${ndir}"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.local/share/$ndir"
    }
  }
  [ "$removeall" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving any ${ndir} plugins backups"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.local/share/$ndir"-bak*
    }
  }

  [ -d "${HOME}/.local/state/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving existing ${ndir} state at ${HOME}/.local/state/${ndir}"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.local/state/$ndir"
    }
  }
  [ "$removeall" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving any ${ndir} state backups"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.local/state/$ndir"-bak*
    }
  }

  [ -d "${HOME}/.cache/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving existing ${ndir} cache at ${HOME}/.cache/${ndir}"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.cache/$ndir"
    }
  }
  [ "$removeall" ] && {
    [ "$quiet" ] || {
      printf "\nRemoving any ${ndir} cache backups"
    }
    [ "$tellme" ] || {
      rm -rf "${HOME}/.cache/$ndir"-bak*
    }
  }
  [ "$tellme" ] || {
    remove_nvimdirs_entry "$ndir"
  }
}

update_config() {
  ndir="$1"
  [ -d "${HOME}/.config/$ndir" ] && {
    [ "$quiet" ] || {
      printf "\nUpdating existing ${ndir} config at ${HOME}/.config/${ndir} ..."
    }
    [ "$tellme" ] || {
      git -C "${HOME}/.config/$ndir" stash >/dev/null 2>&1
      # git -C "${HOME}/.config/$ndir" pull >/dev/null 2>&1
      # git -C "${HOME}/.config/$ndir" stash pop >/dev/null 2>&1
      git -C "${HOME}/.config/$ndir" fetch origin >/dev/null 2>&1
      git -C "${HOME}/.config/$ndir" reset --hard origin/local >/dev/null 2>&1
    }
    [ "$quiet" ] || {
      printf " done"
    }
    add_nvimdirs_entry "$ndir"
  }
  [ "$ndir" == "$astronvimdir" ] || [ "$ndir" == "$nvchaddir" ] && {
    if [ "$ndir" == "$astronvimdir" ]; then
      cdir="lua/user"
    else
      cdir="lua/custom"
    fi
    [ -d "${HOME}/.config/$ndir/$cdir" ] && {
      [ "$quiet" ] || {
        printf "\nUpdating existing add-on config at ${HOME}/.config/${ndir}/${cdir} ..."
      }
      [ "$tellme" ] || {
        git -C "${HOME}/.config/$ndir/$cdir" stash >/dev/null 2>&1
        # git -C "${HOME}/.config/$ndir/$cdir" pull >/dev/null 2>&1
        # git -C "${HOME}/.config/$ndir/$cdir" stash pop >/dev/null 2>&1
        git -C "${HOME}/.config/$ndir/$cdir" fetch origin >/dev/null 2>&1
        git -C "${HOME}/.config/$ndir"/$cdir reset --hard origin/local >/dev/null 2>&1
      }
      [ "$quiet" ] || {
        printf " done"
      }
    }
  }
}

set_brew() {
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    HOMEBREW_HOME="/home/linuxbrew/.linuxbrew"
  else
    if [ -x /usr/local/bin/brew ]; then
      HOMEBREW_HOME="/usr/local"
    else
      if [ -x /opt/homebrew/bin/brew ]; then
        HOMEBREW_HOME="/opt/homebrew"
      else
        HOMEBREW_HOME=
      fi
    fi
  fi
  if [ "$HOMEBREW_HOME" ]; then
    BREW_EXE=
  else
    BREW_EXE="${HOMEBREW_HOME}/bin/brew"
  fi
}

clone_repo() {
  reponame="$1"
  repourl="$2"
  repodest="$3"
  [ -d "${HOME}/.config/$repodest" ] || {
    [ "$quiet" ] || {
      printf "\nCloning ${reponame} configuration into"
      printf "\n\t${HOME}/.config/${repodest} ... "
    }
    [ "$tellme" ] || {
      git clone \
        https://github.com/"$repourl" \
        "${HOME}/.config/${repodest}" >/dev/null 2>&1
      add_nvimdirs_entry "$repodest"
    }
    [ "$quiet" ] || printf "done"
  }
}

show_figlet() {
  # Seed random generator
  RANDOM=$$$(date +%s)
  USE_FONT=${fonts[$RANDOM % ${#fonts[@]}]}
  [ "${USE_FONT}" ] || USE_FONT="standard"
  if [ "${have_lolcat}" ]; then
    if [ "${USE_FONT}" == "lean" ]; then
      figlet -c -f "${USE_FONT}" -k -t ${FIG_TEXT} 2>/dev/null | tr ' _/' ' ()' | ${LOLCAT}
    else
      figlet -c -f "${USE_FONT}" -k -t ${FIG_TEXT} 2>/dev/null | ${LOLCAT}
    fi
  else
    if [ "${USE_FONT}" == "lean" ]; then
      figlet -c -f "${USE_FONT}" -k -t ${FIG_TEXT} 2>/dev/null | tr ' _/' ' ()'
    else
      figlet -c -f "${USE_FONT}" -k -t ${FIG_TEXT} 2>/dev/null
    fi
  fi
}

show_info() {
  [ -f "${LMANDIR}"/.lazymanrc ] && {
    source "${LMANDIR}"/.lazymanrc
  }
  readarray -t sorted < <(printf '%s\0' "${ndirs[@]}" | sort -z | xargs -0n1)
  numitems=${#sorted[@]}
  if alias nvims >/dev/null 2>&1; then
    printf "\nThe 'nvims' alias exists:"
    nvims_alias=$(alias nvims)
    printf "\n\t${nvims_alias}"
  else
    printf "\nThe 'nvims' alias does not exist"
    printf "\nSource $HOME/.config/nvim-Lazyman/.lazymanrc in your shell initialization,"
    printf "\nlogout and login"
  fi
  if [ "${have_neovide}" ]; then
    printf "\n\nThe neovide Neovim GUI is installed"
    if alias neovides >/dev/null 2>&1; then
      printf "\n\nThe 'neovides' alias exists:"
      neovides_alias=$(alias neovides)
      printf "\n\t${neovides_alias}"
    else
      printf "\n\nThe 'neovides' alias does not exist"
    fi
  else
    printf "\n\nThe neovide Neovim GUI is not installed"
  fi
  printf "\n\n${numitems} Lazyman Neovim configurations installed:\n"
  for neovim in "${sorted[@]}"; do
    if [ -d ${HOME}/.config/${neovim} ]; then
      printf "\n\t${HOME}/.config/${neovim}"
    else
      printf "\n\tMissing ${HOME}/.config/${neovim} !"
    fi
  done
  nvim_version=$(nvim --version)
  printf "\n\nInstalled Neovim version info:\n\n${nvim_version}\n"
}

show_alias() {
  adir="$1"
  printf "\nAn alias for this Lazyman configuration can be created with:"
  if [ "$all" ]; then
    printf "\n\talias lnvim='NVIM_APPNAME=${LAZYMAN} nvim'"
  elif [ "$astronvim" ]; then
    printf "\n\talias avim='NVIM_APPNAME=nvim-AstroNvim nvim'"
  elif [ "$ecovim" ]; then
    printf "\n\talias evim='NVIM_APPNAME=nvim-Ecovim nvim'"
  elif [ "$kickstart" ]; then
    printf "\n\talias kvim='NVIM_APPNAME=nvim-Kickstart nvim'"
  elif [ "$lazyman" ]; then
    printf "\n\talias lmvim='NVIM_APPNAME=${LAZYMAN} nvim'"
  elif [ "$lazyvim" ]; then
    printf "\n\talias lvim='NVIM_APPNAME=nvim-LazyVim nvim'"
  elif [ "$lunarvim" ]; then
    printf "\n\talias lvim='NVIM_APPNAME=nvim-LunarVim nvim'"
  elif [ "$spacevim" ]; then
    printf "\n\talias svim='NVIM_APPNAME=nvim-SpaceVim nvim'"
  elif [ "$nvchad" ]; then
    printf "\n\talias cvim='NVIM_APPNAME=nvim-NvChad nvim'"
  elif [ "$magicvim" ]; then
    printf "\n\talias mvim='NVIM_APPNAME=nvim-MagicVim nvim'"
  else
    printf "\n\talias lmvim=\"NVIM_APPNAME=${adir} nvim\""
  fi
  printf "\n"
}

set_haves() {
  have_brew=$(type -p brew)
  have_cargo=$(type -p cargo)
  have_neovide=$(type -p neovide)
  have_figlet=$(type -p figlet)
  have_tscli=$(type -p tree-sitter)
  have_prettier=$(type -p prettier)
  have_lolcat=$(type -p lolcat)
  have_rich=$(type -p rich)
  have_xclip=$(type -p xclip)
}

show_menu() {
  [ -f "${LMANDIR}"/.lazymanrc ] && source "${LMANDIR}"/.lazymanrc
  set_haves

  while true; do
    if [ "${USEGUI}" ]; then
      use_gui="neovide"
    else
      use_gui="neovim"
    fi
    clear
    [ "${have_figlet}" ] && show_figlet
    items=()
    showinstalled=1
    if [ -f "${LMANDIR}"/.lazymanrc ]; then
      source "${LMANDIR}"/.lazymanrc
    else
      if [ "${have_rich}" ]; then
        rich "[bold red]WARNING[/]: missing [b yellow]${LMANDIR}/.lazymanrc[/]
  reinstall Lazyman with:
    [bold green]lazyman -R -N ${LAZYMAN}[/]
  followed by:
    [bold green]lazyman[/]" -p -a rounded -c
      else
        printf "\nWARNING: missing ${LMANDIR}/.lazymanrc"
        printf "\nReinstall Lazyman with:"
        printf "\n\tlazyman -R -N ${LAZYMAN}"
        printf "\n\tlazyman\n"
      fi
      showinstalled=
    fi
    readarray -t sorted < <(printf '%s\0' "${items[@]}" | sort -z | xargs -0n1)
    numitems=${#sorted[@]}
    confword="configurations"
    [ ${numitems} -eq 1 ] && confword="configuration"
    if [ "${have_rich}" ]; then
      rich "[b magenta]${numitems} Lazyman[/] [b green]Neovim ${confword}[/] [b magenta]installed[/]" -p -c
    else
      printf "\n${numitems} Lazyman Neovim configurations installed:\n"
    fi
    [ "${showinstalled}" ] && {
      linelen=0
      if [ "${have_rich}" ]; then
        neovims=""
        leader="[b green]"
        for neovim in "${sorted[@]}"; do
          neovims="${neovims} ${leader}${neovim}[/]"
          if [ "${leader}" == "[b green]" ]; then
            leader="[b magenta]"
          else
            leader="[b green]"
          fi
        done
        rich "${neovims}" -p -a rounded -c -C -w 78
      else
        printf "\t"
        for neovim in "${sorted[@]}"; do
          printf "${neovim}  "
          nvsz=${#neovim}
          linelen=$((linelen + nvsz + 2))
          [ ${linelen} -gt 50 ] && {
            printf "\n\t"
            linelen=0
          }
        done
        printf "\n\n"
      fi
    }

    PS3="${BOLD}${PLEASE} choice (numeric or text, 'h' for help): ${NORM}"
    options=()
    if [ "${USEGUI}" ]; then
      if [ "${have_neovide}" ]; then
        if alias neovides >/dev/null 2>&1; then
          [ ${numitems} -gt 1 ] && options+=("Select Config")
        else
          options+=("Open Neovide")
          if alias nvims >/dev/null 2>&1; then
            USEGUI=
            use_gui="neovim"
            [ ${numitems} -gt 1 ] && options+=("Select Config")
          fi
        fi
      else
        USEGUI=
        use_gui="neovim"
        options+=("Install Neovide")
        if alias nvims >/dev/null 2>&1; then
          [ ${numitems} -gt 1 ] && options+=("Select Config")
        fi
      fi
    else
      if alias nvims >/dev/null 2>&1; then
        [ ${numitems} -gt 1 ] && options+=("Select Config")
      fi
    fi
    installed=1
    partial=
    get_config_str "${BASECFGS}"
    base_installed=${installed}
    options+=("Install Base ${configstr}")
    installed=1
    partial=
    get_config_str "${EXTRACFGS}"
    extra_installed=${installed}
    options+=("Install Extras ${configstr}")
    installed=1
    partial=
    get_config_str "${STARTCFGS}"
    options+=("Install Starters ${configstr}")
    installed=1
    partial=
    get_config_str "${BASECFGS} ${EXTRACFGS} ${STARTCFGS}"
    options+=("Install All ${configstr}")
    [[ "${have_figlet}" && "${have_tscli}" && "${have_xclip}" && "${have_prettier}" ]] || {
      options+=("Install Tools")
    }
    options+=("Remove Base")
    options+=("Remove Extras")
    options+=("Remove Starters")
    options+=("Remove All")
    if [ "${base_installed}" ]; then
      if [ "${extra_installed}" ]; then
        for neovim in ${STARTCFGS}; do
          if [[ ! " ${sorted[*]} " =~ " ${neovim} " ]]; then
            nvdir=$(echo "${neovim}" | sed -e "s/starter-//")
            options+=("Install ${nvdir}")
          fi
        done
      else
        for neovim in ${EXTRACFGS}; do
          nvdir=$(echo "${neovim}" | sed -e "s/nvim-//")
          if [[ ! " ${sorted[*]} " =~ " ${nvdir} " ]]; then
            options+=("Install ${nvdir}")
          fi
        done
      fi
    else
      for neovim in "${basenvimdirs[@]}"; do
        nvdir=$(echo "${neovim}" | sed -e "s/nvim-//")
        if [[ ! " ${sorted[*]} " =~ " ${nvdir} " ]]; then
          options+=("Install ${nvdir}")
        fi
      done
    fi
    for neovim in "${sorted[@]}"; do
      echo ${neovim} | grep ^starter- >/dev/null || {
        options+=("Open ${neovim}")
      }
    done
    for neovim in "${sorted[@]}"; do
      echo ${neovim} | grep ^starter- >/dev/null && {
        options+=("Open Starter Config")
        break
      }
    done
    if [ "${have_neovide}" ]; then
      options+=("Toggle [${use_gui}]")
    fi
    options+=("Lazyman Status")
    options+=("Quit")
    select opt in "${options[@]}"; do
      case "$opt,$REPLY" in
        "h",* | *,"h" | "H",* | *,"H" | "help",* | *,"help" | "Help",* | *,"Help")
          clear
          printf "\n"
          man lazyman
          break
          ;;
        "Select Config"*,* | *,"Select Config"*)
          if [ "${USEGUI}" ]; then
            neovselect
          else
            nvimselect
          fi
          break
          ;;
        "Install Base"*,* | *,"Install Base"*)
          lazyman -A -y -z
          break
          ;;
        "Install Extra"*,* | *,"Install Extra"*)
          lazyman -W -y -z
          break
          ;;
        "Install Starter"*,* | *,"Install Starter"*)
          lazyman -X -y -z
          break
          ;;
        "Install All"*,* | *,"Install All"*)
          lazyman -A -y -z
          lazyman -W -y -z
          lazyman -X -y -z
          break
          ;;
        "Install Tools"*,* | *,"Install Tools"*)
          lazyman -I
          set_haves
          break
          ;;
        "Install Neovide"*,* | *,"Install Neovide"*)
          [ "${have_cargo}" ] || {
            printf "\nNeovide build requires cargo but cargo not found.\n"
            while true; do
              read -r -p "Do you wish to install cargo now ? (y/n) " yn
              case $yn in
                [Yy]*)
                  printf "\nInstalling cargo ..."
                  if [ "${have_brew}" ]; then
                    brew install rust >/dev/null 2>&1
                  else
                    RUST_URL="https://sh.rustup.rs"
                    curl -fsSL "${RUST_URL}" >/tmp/rust-$$.sh
                    [ $? -eq 0 ] || {
                      rm -f /tmp/rust-$$.sh
                      curl -kfsSL "${RUST_URL}" >/tmp/rust-$$.sh
                      [ -f /tmp/rust-$$.sh ] && {
                        cat /tmp/rust-$$.sh | sed -e "s/--show-error/--insecure --show-error/" >/tmp/ins$$
                        cp /tmp/ins$$ /tmp/rust-$$.sh
                        rm -f /tmp/ins$$
                      }
                    }
                    [ -f /tmp/rust-$$.sh ] && sh /tmp/rust-$$.sh -y >/dev/null 2>&1
                    rm -f /tmp/rust-$$.sh
                  fi
                  printf " done"
                  break
                  ;;
                [Nn]*)
                  printf "\nAborting cargo and neovide install\n"
                  break 2
                  ;;
                *)
                  printf "\nPlease answer yes or no.\n"
                  ;;
              esac
            done
            have_cargo=$(type -p cargo)
          }
          if [ "${have_cargo}" ]; then
            printf "\nBuilding Neovide GUI, please be patient ... "
            cargo install --git https://github.com/neovide/neovide >/dev/null 2>&1
            printf "done\n"
            have_neovide=$(type -p neovide)
          else
            printf "\nCannot locate cargo. Perhaps it is not in your PATH."
            printf "\nUnable to build Neovide"
          fi
          [ -f "${LMANDIR}"/.lazymanrc ] && {
            source "${LMANDIR}"/.lazymanrc
          }
          break
          ;;
        "Install "*,* | *,"Install "*)
          nvimconf=$(echo ${opt} | awk ' { print $2 } ')
          case ${nvimconf} in
            AstroNvim)
              lazyman -a -z -y
              ;;
            Ecovim)
              lazyman -e -z -y
              ;;
            Kickstart)
              lazyman -k -z -y
              ;;
            Lazyman)
              lazyman -i -z -y
              ;;
            LazyVim)
              lazyman -l -z -y
              ;;
            LunarVim)
              lazyman -v -z -y
              ;;
            NvChad)
              lazyman -c -z -y
              ;;
            SpaceVim)
              lazyman -s -z -y
              ;;
            MagicVim)
              lazyman -m -z -y
              ;;
            Nv)
              lazyman -w Nv -z -y
              ;;
            Abstract)
              lazyman -w Abstract -z -y
              ;;
            Allaman)
              lazyman -w Allaman -z -y
              ;;
            Fennel)
              lazyman -w Fennel -z -y
              ;;
            NvPak)
              lazyman -w NvPak -z -y
              ;;
            Optixal)
              lazyman -w Optixal -z -y
              ;;
            Plug)
              lazyman -w Plug -z -y
              ;;
            Heiker)
              lazyman -w Heiker -z -y
              ;;
            Minimal)
              lazyman -x Minimal -z -y
              ;;
            StartBase)
              lazyman -x StartBase -z -y
              ;;
            Opinion)
              lazyman -x Opinion -z -y
              ;;
            Lsp)
              lazyman -x Lsp -z -y
              ;;
            Mason)
              lazyman -x Mason -z -y
              ;;
            Modular)
              lazyman -x Modular -z -y
              ;;
          esac
          break
          ;;
        "Open Neovide"*,* | *,"Open Neovide"*)
          NVIM_APPNAME="${LAZYMAN}" neovide
          break
          ;;
        "Open Starter"*,* | *,"Open Starter"*)
          if [ "${USEGUI}" ]; then
            neovselect starter
          else
            nvimselect starter
          fi
          break
          ;;
        "Open "*,* | *,"Open "*)
          nvimconf=$(echo ${opt} | awk ' { print $2 } ')
          if [ -d "${HOME}/.config/nvim-${nvimconf}" ]; then
            if [ "${USEGUI}" ]; then
              NVIM_APPNAME="nvim-${nvimconf}" neovide
            else
              NVIM_APPNAME="nvim-${nvimconf}" nvim
            fi
          else
            if [ -d "${HOME}/.config/${nvimconf}" ]; then
              if [ "${USEGUI}" ]; then
                NVIM_APPNAME="${nvimconf}" neovide
              else
                NVIM_APPNAME="${nvimconf}" nvim
              fi
            else
              printf "\nCannot locate ${nvimconf} Neovim configuration\n"
              printf "\nPress Enter to continue\n"
              read -r yn
            fi
          fi
          break
          ;;
        "Remove Base"*,* | *,"Remove Base"*)
          lazyman -R -A -y
          break
          ;;
        "Remove Extra"*,* | *,"Remove Extra"*)
          lazyman -R -W -y
          break
          ;;
        "Remove Starter"*,* | *,"Remove Starter"*)
          lazyman -R -X -y
          break
          ;;
        "Remove All"*,* | *,"Remove All"*)
          for ndirm in "${ndirs[@]}"; do
            [ "${ndirm}" == "${LAZYMAN}" ] && continue
            [ "${ndirm}" == "nvim" ] && continue
            lazyman -R -N ${ndirm} -y
          done
          break
          ;;
        "Toggle"*,* | *,"Toggle"*)
          if [ "${USEGUI}" ]; then
            USEGUI=
          else
            USEGUI=1
          fi
          break
          ;;
        "Lazyman Status",* | *,"Lazyman Status")
          show_info >/tmp/lminfo$$
          if [ "${USEGUI}" ]; then
            NVIM_APPNAME="${LAZYMAN}" neovide /tmp/lminfo$$
          else
            NVIM_APPNAME="${LAZYMAN}" nvim /tmp/lminfo$$
          fi
          rm -f /tmp/lminfo$$
          break
          ;;
        "Quit",* | *,"Quit" | "quit",* | *,"quit")
          printf "\nExiting Lazyman\n"
          exit 0
          ;;
        *,*)
          printf "\nCould not match '${REPLY}' with a menu entry."
          printf "\nPlease try again with an exact match.\n"
          [ "${have_figlet}" ] && show_figlet
          ;;
      esac
      REPLY=
    done
  done
}

get_config_str() {
  CFGS="$1"
  for cfg in ${CFGS}; do
    inst=
    for bdir in "${sorted[@]}"; do
      [[ $cfg == "$bdir" ]] && {
        partial=1
        inst=1
        break
      }
    done
    [ "${inst}" ] || installed=
  done
  if [ "${installed}" ]; then
    configstr=" "
  else
    if [ "${partial}" ]; then
      configstr=" "
    else
      configstr=""
    fi
  fi
}

set_starter_branch() {
  starter="$1"
  case ${starter} in
    Minimal)
      startbranch="00-minimal"
      ;;
    StartBase)
      startbranch="01-base"
      ;;
    Opinion)
      startbranch="02-opinionated"
      ;;
    Lsp)
      startbranch="03-lsp"
      ;;
    Mason)
      startbranch="04-lsp-installer"
      ;;
    Modular)
      startbranch="05-modular"
      ;;
    *)
      printf "\nUnrecognized nvim-starter configuration: ${nvimstarter}"
      printf "\nPress Enter to continue\n"
      read -r yn
      usage
      ;;
  esac
}

all=
branch=
instnvim=1
subdir=
command=
debug=
invoke=
langservers=
tellme=
astronvim=
ecovim=
kickstart=
lazyman=
lazyvim=
lunarvim=
magicvim=
nvchad=
nvimextra=
nvimstarter=
spacevim=
plug=
packer=
proceed=
quiet=
remove=
removeall=
runvim=1
select=
update=
url=
name=
pmgr="Lazy"
lazymandir="${LAZYMAN}"
astronvimdir="nvim-AstroNvim"
ecovimdir="nvim-Ecovim"
kickstartdir="nvim-Kickstart"
lazyvimdir="nvim-LazyVim"
lunarvimdir="nvim-LunarVim"
nvchaddir="nvim-NvChad"
spacevimdir="nvim-SpaceVim"
magicvimdir="nvim-MagicVim"
basenvimdirs=("$lazymandir" "$lazyvimdir" "$magicvimdir" "$spacevimdir" "$ecovimdir" "$astronvimdir" "$nvchaddir" "$lunarvimdir")
nvimdir=()
while getopts "aAb:cdD:eE:iIklmnL:pPqrRsSUC:N:vw:Wx:XyzZu" flag; do
  case $flag in
    a)
      astronvim=1
      nvimdir=("$astronvimdir")
      ;;
    A)
      all=1
      astronvim=1
      ecovim=1
      lazyman=1
      lazyvim=1
      lunarvim=1
      magicvim=1
      nvchad=1
      spacevim=1
      nvimdir=("${basenvimdirs[@]}")
      ;;
    b)
      branch="$OPTARG"
      ;;
    c)
      nvchad=1
      nvimdir=("$nvchaddir")
      ;;
    d)
      debug="-d"
      ;;
    e)
      ecovim=1
      nvimdir=("$ecovimdir")
      ;;
    E)
      invoke="$OPTARG"
      ;;
    i)
      lazyman=1
      nvimdir=("$lazymandir")
      ;;
    I)
      langservers=1
      ;;
    k)
      kickstart=1
      nvimdir=("$kickstartdir")
      ;;
    l)
      lazyvim=1
      nvimdir=("$lazyvimdir")
      ;;
    L)
      command="$OPTARG"
      ;;
    m)
      magicvim=1
      nvimdir=("$magicvimdir")
      ;;
    n)
      tellme=1
      ;;
    p)
      plug=1
      pmgr="Plug"
      ;;
    P)
      packer=1
      pmgr="Packer"
      ;;
    q)
      quiet=1
      ;;
    r)
      remove=1
      ;;
    R)
      remove=1
      removeall=1
      ;;
    s)
      spacevim=1
      nvimdir=("$spacevimdir")
      ;;
    S)
      select=1
      ;;
    C)
      url="$OPTARG"
      ;;
    D)
      subdir="$OPTARG"
      ;;
    N)
      name="$OPTARG"
      ;;
    U)
      update=1
      ;;
    v)
      lunarvim=1
      nvimdir=("$lunarvimdir")
      ;;
    w)
      nvimextra="$OPTARG"
      ;;
    W)
      nvimextra="all"
      ;;
    x)
      nvimstarter="$OPTARG"
      ;;
    X)
      nvimstarter="all"
      ;;
    y)
      proceed=1
      ;;
    z)
      runvim=
      ;;
    Z)
      instnvim=
      ;;
    u)
      usage
      ;;
    *)
      printf "\nUnrecognized option. Exiting.\n"
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

[ "$select" ] && {
  if [ -f "${LMANDIR}"/.lazymanrc ]; then
    source "${LMANDIR}"/.lazymanrc
  else
    printf "\nWARNING: missing ${LMANDIR}/.lazymanrc"
    printf "\nReinstall Lazyman with:"
    printf "\n\tlazyman -R -N ${LAZYMAN}"
    printf "\n\tlazyman\n"
  fi
  if alias nvims >/dev/null 2>&1; then
    nvimselect "$@"
  fi
  exit 0
}

[ "$nvimextra" ] && {
  if [ "$remove" ]; then
    if [ "${nvimextra}" == "all" ]; then
      for neovim in Nv Abstract Allaman Fennel NvPak Optixal Plug Heiker; do
        remove_config "nvim-${neovim}"
      done
    else
      remove_config "nvim-${nvimextra}"
    fi
  else
    yesflag=
    [ "${proceed}" ] && yesflag="-y"
    quietflag=
    [ "${quiet}" ] && quietflag="-q"
    if [ "${nvimextra}" == "all" ]; then
      action="Installing"
      [ -d ${HOME}/.config/nvim-Nv ] && action="Updating"
      printf "\n${action} Nv Neovim configuration ..."
      lazyman -C https://github.com/appelgriebsch/Nv \
        -N nvim-Nv -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Nv"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Abstract ] && action="Updating"
      printf "\n${action} Abstract Neovim configuration ..."
      lazyman -C https://github.com/Abstract-IDE/Abstract \
        -N nvim-Abstract -P -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Abstract"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Fennel ] && action="Updating"
      printf "\n${action} Fennel Neovim configuration ..."
      lazyman -C https://github.com/jhchabran/nvim-config \
        -N nvim-Fennel -P -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Fennel"
      action="Installing"
      [ -d ${HOME}/.config/nvim-NvPak ] && action="Updating"
      printf "\n${action} NvPak Neovim configuration ..."
      lazyman -C https://github.com/Pakrohk-DotFiles/NvPak.git \
        -N nvim-NvPak -q -z ${yesflag}
      printf " done"
      show_alias "nvim-NvPak"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Optixal ] && action="Updating"
      printf "\n${action} Optixal Neovim configuration ..."
      lazyman -C https://github.com/Optixal/neovim-init.vim \
        -N nvim-Optixal -p -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Optixal"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Plug ] && action="Updating"
      printf "\n${action} Plug Neovim configuration ..."
      lazyman -C https://github.com/doctorfree/nvim-plug \
        -N nvim-Plug -p -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Plug"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Heiker ] && action="Updating"
      printf "\n${action} VonHeikemen Neovim configuration ..."
      lazyman -C https://github.com/VonHeikemen/dotfiles \
        -D my-configs/neovim -N nvim-Heiker -q -z ${yesflag}
      printf " done"
      show_alias "nvim-Heiker"
      action="Installing"
      [ -d ${HOME}/.config/nvim-Allaman ] && action="Updating"
      printf "\n${action} Allaman Neovim configuration ..."
      lazyman -C https://github.com/Allaman/nvim \
        -N nvim-Allaman -q -z ${yesflag}
      printf " done\n"
      show_alias "nvim-Allaman"
    else
      extra_url=
      extra_dir=
      extra_opt=
      runflag=
      [ "${runvim}" ] || runflag="-z"
      case ${nvimextra} in
        Abstract)
          extra_url="https://github.com/Abstract-IDE/Abstract"
          extra_opt="-P"
          ;;
        Allaman)
          extra_url="https://github.com/Allaman/nvim"
          ;;
        Fennel)
          extra_url="https://github.com/jhchabran/nvim-config"
          extra_opt="-P"
          ;;
        Nv)
          extra_url="https://github.com/appelgriebsch/Nv"
          ;;
        NvPak)
          extra_url="https://github.com/Pakrohk-DotFiles/NvPak.git"
          ;;
        Optixal)
          extra_url="https://github.com/Optixal/neovim-init.vim"
          extra_opt="-p"
          ;;
        Plug)
          extra_url="https://github.com/doctorfree/nvim-plug"
          extra_opt="-p"
          ;;
        Heiker)
          extra_url="https://github.com/VonHeikemen/dotfiles"
          extra_dir="-D my-configs/neovim"
          ;;
        *)
          printf "\nUnrecognized extra configuration: ${nvimextra}"
          printf "\nPress Enter to continue\n"
          read -r yn
          usage
          ;;
      esac
      action="Installing"
      [ -d ${HOME}/.config/nvim-${nvimextra} ] && action="Updating"
      printf "\n${action} ${nvimextra} Neovim configuration ..."
      lazyman -C ${extra_url} -N nvim-${nvimextra} ${extra_dir} ${extra_opt} \
        ${quietflag} ${runflag} ${yesflag}
      printf " done"
    fi
  fi
  exit 0
}

[ "$nvimstarter" ] && {
  if [ "$remove" ]; then
    if [ "${nvimstarter}" == "all" ]; then
      for neovim in Minimal StartBase Opinion Lsp Mason Modular; do
        remove_config "nvim-starter-${neovim}"
      done
    else
      remove_config "nvim-starter-${nvimstarter}"
    fi
  else
    yesflag=
    [ "${proceed}" ] && yesflag="-y"
    quietflag=
    [ "${quiet}" ] && quietflag="-q"
    if [ "${nvimstarter}" == "all" ]; then
      for neovim in Minimal StartBase Opinion Lsp Mason Modular; do
        startbranch=
        set_starter_branch "${neovim}"
        [ "${startbranch}" ] || usage
        action="Installing"
        [ -d ${HOME}/.config/nvim-starter-${neovim} ] && action="Updating"
        printf "\n${action} nvim-starter ${neovim} Neovim configuration ..."
        lazyman -C https://github.com/VonHeikemen/nvim-starter \
          -N nvim-starter-${neovim} -b ${startbranch} -q -z ${yesflag}
        printf " done"
        show_alias "nvim-starter-${neovim}"
      done
    else
      runflag=
      [ "${runvim}" ] || runflag="-z"
      startbranch=
      set_starter_branch "${nvimstarter}"
      [ "${startbranch}" ] || usage
      action="Installing"
      [ -d ${HOME}/.config/nvim-starter-${nvimstarter} ] && action="Updating"
      printf "\n${action} nvim-starter ${nvimstarter} Neovim configuration ..."
      lazyman -C https://github.com/VonHeikemen/nvim-starter \
        -N nvim-starter-${nvimstarter} -b ${startbranch} \
        ${quietflag} ${runflag} ${yesflag}
      printf " done"
    fi
  fi
  printf "\n"
  exit 0
}

[ "$langservers" ] && {
  [ "${instnvim}" ] || {
    printf "\n\n-I and -Z are incompatible options."
    printf "\nThe '-I' option indicates install tools."
    printf "\nThe '-Z' option indicates do not install tools."
    brief_usage
  }
  if [ -x "${HOME}/.config/${lazymandir}/scripts/install_neovim.sh" ]; then
    "${HOME}/.config/$lazymandir"/scripts/install_neovim.sh "$debug"
    exit 0
  fi
  exit 1
}

[ "$url" ] && {
  [ "$name" ] || {
    printf "\nERROR: '-C url' must be accompanied with '-N nvimdir'\n"
    brief_usage
  }
}
[ "$all" ] && [ "$name" ] && {
  printf "\nERROR: '-A' cannot be used with '-N nvimdir'\n"
  brief_usage
}
[ "$packer" ] && [ "$plug" ] && {
  printf "\nERROR: '-P' cannot be used with '-p'"
  printf "\nOnly one plugin manager can be specified\n"
  brief_usage
}
# Support specifying '-N nvimdir' with supported configurations
# This breaks subsequent '-E' invocations for that config
[ "$name" ] && {
  numvim=0
  [ "$astronvim" ] && numvim=$((numvim + 1))
  [ "$ecovim" ] && numvim=$((numvim + 1))
  [ "$kickstart" ] && numvim=$((numvim + 1))
  [ "$lazyvim" ] && numvim=$((numvim + 1))
  [ "$lazyman" ] && numvim=$((numvim + 1))
  [ "$lunarvim" ] && numvim=$((numvim + 1))
  [ "$magicvim" ] && numvim=$((numvim + 1))
  [ "$nvchad" ] && numvim=$((numvim + 1))
  [ "$spacevim" ] && numvim=$((numvim + 1))
  [ "$numvim" -gt 1 ] && {
    printf "\nERROR: multiple Neovim configs cannot be used with '-N nvimdir'\n"
    brief_usage
  }
  [ "$astronvim" ] && astronvimdir="$name"
  [ "$ecovim" ] && ecovimdir="$name"
  [ "$kickstart" ] && kickstartdir="$name"
  [ "$lazyman" ] && lazymandir="$name"
  [ "$lazyvim" ] && lazyvimdir="$name"
  [ "$lunarvim" ] && lunarvimdir="$name"
  [ "$magicvim" ] && magicvimdir="$name"
  [ "$nvchad" ] && nvchaddir="$name"
  [ "$spacevim" ] && spacevimdir="$name"
  [ "$numvim" -eq 1 ] && {
    [ "$quiet" ] || {
      printf "\nWARNING: Specifying '-N nvimdir' will change the configuration location"
      printf "\n\tof a supported config to ${name}"
      printf "\n\tThis will make it incompatible with '-E <config>' in subsequent runs\n"
    }
    [ "$proceed" ] || {
      printf "\nDo you wish to proceed with this non-standard initialization?"
      while true; do
        read -r -p "Proceed with config in ${name} ? (y/n) " yn
        case $yn in
          [Yy]*)
            break
            ;;
          [Nn]*)
            printf "\nAborting install and exiting\n"
            exit 0
            ;;
          *)
            printf "\nPlease answer yes or no.\n"
            ;;
        esac
      done
    }
  }
}

[ "$invoke" ] && {
  nvimlower=$(echo "$invoke" | tr '[:upper:]' '[:lower:]')
  case "$nvimlower" in
    astronvim)
      ndir="$astronvimdir"
      ;;
    ecovim)
      ndir="$ecovimdir"
      ;;
    kickstart)
      ndir="$kickstartdir"
      ;;
    lazyman)
      ndir="$lazymandir"
      ;;
    lazyvim)
      ndir="$lazyvimdir"
      ;;
    lunarvim)
      ndir="$lunarvimdir"
      ;;
    nvchad)
      ndir="$nvchaddir"
      ;;
    magicvim)
      ndir="$magicvimdir"
      ;;
    spacevim)
      ndir="$spacevimdir"
      ;;
    *)
      ndir="$invoke"
      ;;
  esac
  [ -d "${HOME}/.config/${ndir}" ] || {
    printf "\nNeovim configuration for ${ndir} not found"
    printf "\nExiting\n"
    exit 1
  }
  export NVIM_APPNAME="$ndir"
  nvim "$@"
  exit 0
}

[ "$name" ] && nvimdir=("$name")

[ "$remove" ] && {
  for neovim in "${nvimdir[@]}"; do
    [ "${all}" ] && [ "${neovim}" == "${lazymandir}" ] && continue
    remove_config "$neovim"
  done
  exit 0
}

[ "$command" ] && {
  [ "$all" ] || [ "$name" ] || {
    [ "$NVIM_APPNAME" ] && nvimdir=("$NVIM_APPNAME")
  }
  for neovim in "${nvimdir[@]}"; do
    run_command "$neovim" "$command"
  done
  exit 0
}

[ "$update" ] && {
  [ "$all" ] || [ "$name" ] || {
    [ "$NVIM_APPNAME" ] && nvimdir=("$NVIM_APPNAME")
  }
  for neovim in "${nvimdir[@]}"; do
    update_config "$neovim"
    [ "$tellme" ] || {
      init_neovim "$neovim"
    }
  done
  exit 0
}

have_git=$(type -p git)
[ "$have_git" ] || {
  printf "\nLazyman requires git but git not found"
  printf "\nPlease install git and retry this lazyman command\n"
  brief_usage
}

interactive=
numvimdirs=${#nvimdir[@]}
[ ${numvimdirs} -eq 0 ] && {
  nvimdir=("${lazymandir}")
  interactive=1
  runvim=
}
if [ -d "${HOME}/.config/$lazymandir" ]; then
  [ "$branch" ] && {
    git -C "${HOME}/.config/$lazymandir" checkout "$branch" >/dev/null 2>&1
  }
else
  [ "$quiet" ] || {
    printf "\nCloning ${LAZYMAN} configuration into"
    printf "\n\t${HOME}/.config/${lazymandir} ... "
  }
  [ "$tellme" ] || {
    git clone https://github.com/doctorfree/nvim-lazyman \
      "${HOME}/.config/$lazymandir" >/dev/null 2>&1
    [ "$branch" ] && {
      git -C "${HOME}/.config/$lazymandir" checkout "$branch" >/dev/null 2>&1
    }
  }
  [ "$quiet" ] || printf "done"
  interactive=
  runvim=1
fi
# Always make sure nvim-Lazyman is in .nvimdirs
[ "$tellme" ] || {
  add_nvimdirs_entry "$lazymandir"
}

# Append sourcing of .lazymanrc to shell initialization files
if [ -f "${LMANDIR}"/.lazymanrc ]; then
  for shinit in bashrc zshrc; do
    [ -f "${HOME}/.$shinit" ] || continue
    grep lazymanrc "${HOME}/.$shinit" >/dev/null && continue
    COMM="# Source the Lazyman shell initialization for aliases and nvims selector"
    echo "$COMM" >>"${HOME}/.$shinit"
    TEST_SRC="[ -f ~/.config/${LAZYMAN}/.lazymanrc ] &&"
    SOURCE="source ~/.config/${LAZYMAN}/.lazymanrc"
    echo "${TEST_SRC} ${SOURCE}" >>"${HOME}/.$shinit"
  done
  # Append sourcing of .nvimsbind to shell initialization files
  [ -f "${HOME}/.config/$lazymandir"/.nvimsbind ] && {
    for shinit in bashrc zshrc; do
      [ -f "${HOME}/.$shinit" ] || continue
      grep nvimsbind "${HOME}/.$shinit" >/dev/null && continue
      COMM="# Source the Lazyman shell initialization for nvims key binding"
      echo "$COMM" >>"${HOME}/.$shinit"
      TEST_SRC="[ -f ~/.config/${LAZYMAN}/.nvimsbind ] &&"
      SOURCE="source ~/.config/${LAZYMAN}/.nvimsbind"
      echo "${TEST_SRC} ${SOURCE}" >>"${HOME}/.$shinit"
    done
  }
else
  printf "\nWARNING: missing ${LMANDIR}/.lazymanrc"
  printf "\nReinstall Lazyman with:"
  printf "\n\tlazyman -R -N ${LAZYMAN}"
  printf "\n\tlazyman\n"
fi

# Enable ChatGPT plugin if OPENAI_API_KEY set
[ "$OPENAI_API_KEY" ] && {
  NVIMCONF="${HOME}/.config/${lazymandir}/lua/configuration.lua"
  grep 'conf.enable_chatgpt' "$NVIMCONF" >/dev/null && {
    cat "$NVIMCONF" \
      | sed -e "s/conf.enable_chatgpt.*/conf.enable_chatgpt = true/" >/tmp/nvim$$
    cp /tmp/nvim$$ "$NVIMCONF"
    rm -f /tmp/nvim$$
  }
}

[ "${instnvim}" ] && {
  if [ -x "${HOME}/.config/${lazymandir}/scripts/install_neovim.sh" ]; then
    "${HOME}/.config/$lazymandir"/scripts/install_neovim.sh "$debug"
    BREW_EXE=
    set_brew
    [ "$BREW_EXE" ] && eval "$("$BREW_EXE" shellenv)"
    have_nvim=$(type -p nvim)
    [ "$have_nvim" ] || {
      printf "\nERROR: cannot locate neovim."
      printf "\nHomebrew install failure, manual debug required."
      printf "\n\t'brew update && lazyman -d'."
      printf "\nNeovim 0.9 or later required. Install and retry. Exiting.\n"
      brief_usage
    }
  else
    printf "\n${HOME}/.config/${lazymandir}/scripts/install_neovim.sh not executable"
    printf "\nPlease check the Lazyman installation and retry this install script\n"
    brief_usage
  fi
}

for neovim in "${nvimdir[@]}"; do
  [ "$neovim" == "$lazymandir" ] && continue
  if [ "$proceed" ]; then
    update_config "$neovim"
  else
    [ -d "${HOME}/.config/$neovim" ] && {
      printf "\nYou have requested installation of the ${neovim} Neovim configuration."
      printf "\nIt appears there is a previously installed Neovim configuration at:"
      printf "\n\t${HOME}/.config/${neovim}\n"
      printf "\nThe existing Neovim configuration can be updated or backed up.\n"
      while true; do
        read -r -p "Update ${neovim} ? (y/n) " yn
        case $yn in
          [Yy]*)
            update_config "$neovim"
            break
            ;;
          [Nn]*)
            create_backups "$neovim"
            break
            ;;
          *)
            echo "Please answer yes or no."
            ;;
        esac
      done
    }
  fi
done

[ "$astronvim" ] && {
  clone_repo AstroNvim AstroNvim/AstroNvim "$astronvimdir"
  [ "$quiet" ] || {
    printf "\nAdding user configuration into"
    printf "\n\t${HOME}/.config/${astronvimdir}/lua/user ... "
  }
  [ "$tellme" ] || {
    if [ -d "${HOME}/.config/$astronvimdir"/lua/user ]; then
      update_config "$astronvimdir"/lua/user
    else
      git clone https://github.com/doctorfree/astronvim \
        "${HOME}/.config/$astronvimdir"/lua/user >/dev/null 2>&1
    fi
  }
  [ "$quiet" ] || printf "done"
}
[ "$ecovim" ] && {
  clone_repo Ecovim ecosse3/nvim "$ecovimdir"
}
[ "$kickstart" ] && {
  clone_repo Kickstart nvim-lua/kickstart.nvim.git "$kickstartdir"
}
[ "$lazyvim" ] && {
  clone_repo LazyVim LazyVim/starter "$lazyvimdir"
}
[ "$lunarvim" ] && {
  clone_repo LunarVim LunarVim/LunarVim "$lunarvimdir"
}
[ "$magicvim" ] && {
  [ -d "${HOME}/.config/$magicvimdir" ] || {
    [ "$quiet" ] || {
      printf "\nCloning MagicVim configuration into"
      printf "\n\t${HOME}/.config/${magicvimdir} ... "
    }
    [ "$tellme" ] || {
      git clone \
        https://gitlab.com/GitMaster210/magicvim \
        "${HOME}/.config/${magicvimdir}" >/dev/null 2>&1
      add_nvimdirs_entry "$magicvimdir"
    }
    [ "$quiet" ] || printf "done"
  }
}
[ "$nvchad" ] && {
  [ -d "${HOME}/.config/$nvchaddir" ] || {
    [ "$quiet" ] || {
      printf "\nCloning NvChad configuration into"
      printf "\n\t${HOME}/.config/${nvchaddir} ... "
    }
    [ "$tellme" ] || {
      git clone https://github.com/NvChad/NvChad \
        "${HOME}/.config/${nvchaddir}" --depth 1 >/dev/null 2>&1
      add_nvimdirs_entry "$nvchaddir"
    }
    [ "$quiet" ] || {
      printf "\nAdding custom configuration into"
      printf "\n\t${HOME}/.config/${nvchaddir}/lua/custom ... "
    }
  }
  [ "$tellme" ] || {
    if [ -d "${HOME}/.config/$nvchaddir"/lua/custom ]; then
      update_config "$nvchaddir"/lua/custom
    else
      git clone https://github.com/doctorfree/NvChad-custom \
        "${HOME}/.config/$nvchaddir"/lua/custom >/dev/null 2>&1
      # rm -rf ${HOME}/.config/${nvchaddir}/lua/custom/.git
    fi
  }
  [ "$quiet" ] || printf "done"
}
[ "$spacevim" ] && {
  clone_repo SpaceVim SpaceVim/SpaceVim "$spacevimdir"
}
[ "$url" ] && {
  if [ -d "${HOME}/.config/${nvimdir[0]}" ]; then
    [ "$quiet" ] || {
      printf "\nThe directory ${HOME}/.config/${nvimdir[0]} already exists."
    }
  else
    [ "$quiet" ] || {
      printf "\nCloning ${url} into"
      printf "\n\t${HOME}/.config/${nvimdir[0]} ... "
    }
    [ "$tellme" ] || {
      if [ "${subdir}" ]; then
        [ "${branch}" ] || branch="master"
        # Perform some git tricks here to retrieve a repo subdirectory
        mkdir /tmp/lazyman$$
        cd /tmp/lazyman$$ || {
          printf "\nCreation of /tmp/lazyman$$ temporary directory failed. Exiting."
          exit 1
        }
        git init >/dev/null 2>&1
        git remote add -f origin $url >/dev/null 2>&1
        git config core.sparseCheckout true >/dev/null 2>&1
        [ -d .git/info ] || mkdir -p .git/info
        echo "${subdir}" >>.git/info/sparse-checkout
        git pull origin ${branch} >/dev/null 2>&1
        cd || exit
        mv "/tmp/lazyman$$/${subdir}" "${HOME}/.config/${nvimdir[0]}"
        rm -rf "/tmp/lazyman$$"
      else
        git clone \
          "$url" "${HOME}/.config/${nvimdir[0]}" >/dev/null 2>&1
        [ "$branch" ] && {
          git -C "${HOME}/.config/${nvimdir[0]}" checkout "$branch" >/dev/null 2>&1
        }
      fi
      [ -f ${HOME}/.config/${nvimdir[0]}/lua/user/env.sample ] && {
        [ -f ${HOME}/.config/${nvimdir[0]}/lua/user/env.lua ] || {
          cp ${HOME}/.config/${nvimdir[0]}/lua/user/env.sample \
            ${HOME}/.config/${nvimdir[0]}/lua/user/env.lua
        }
      }
      add_nvimdirs_entry "${nvimdir[0]}"
    }
    [ "$quiet" ] || printf "done"
  fi
}

currlimit=$(ulimit -n)
hardlimit=$(ulimit -Hn)
[ "$hardlimit" == "unlimited" ] && hardlimit=9999
if [ "$hardlimit" -gt 4096 ]; then
  [ "$tellme" ] || ulimit -n 4096
else
  [ "$tellme" ] || ulimit -n "$hardlimit"
fi

[ "$interactive" ] || {
  for neovim in "${nvimdir[@]}"; do
    [ "$quiet" ] || {
      pm="$pmgr"
      [ "$neovim" == "$spacevimdir" ] && pm="SP"
      [ "$neovim" == "$magicvimdir" ] && pm="Packer"
      printf "\nInitializing ${neovim} Neovim configuration with ${pm}"
    }
    [ "$tellme" ] || {
      init_neovim "$neovim"
    }
  done
}

[ "$tellme" ] || ulimit -n "$currlimit"

lazyinst=
if [ -f "$HOME"/.local/bin/lazyman ]; then
  [ -f "${LMANDIR}"/lazyman.sh ] && {
    diff "${LMANDIR}"/lazyman.sh "$HOME"/.local/bin/lazyman >/dev/null || lazyinst=1
  }
else
  lazyinst=1
fi
[ "$lazyinst" ] && {
  [ "$quiet" ] || {
    printf "\nInstalling lazyman command in ${HOME}/.local/bin"
    printf "\nUse 'lazyman' to explore Neovim configurations."
    printf "\nReview the lazyman usage message with 'lazyman -u'"
  }
}

maninst=
if [ -f "$HOME"/.local/share/man/man1/lazyman.1 ]; then
  [ -f "${LMANDIR}"/man/man1/lazyman.1 ] && {
    diff "${LMANDIR}"/man/man1/lazyman.1 \
      "$HOME"/.local/share/man/man1/lazyman.1 >/dev/null || maninst=1
  }
else
  maninst=1
fi
[ "$maninst" ] && {
  [ "$quiet" ] || printf "\nView the lazyman man page with 'man lazyman'"
}

[ "$quiet" ] || [ "$interactive" ] || {
  printf "\n\nTo use this lazyman installed Neovim configuration as the default,"
  printf "\nadd a line like the following to your .bashrc or .zshrc:\n"
  if [ "$all" ]; then
    printf '\n\texport NVIM_APPNAME="${LAZYMAN}"\n'
  else
    printf "\n\texport NVIM_APPNAME=\"${nvimdir[0]}\"\n"
  fi
  printf "\nTo easily switch between lazyman installed Neovim configurations,"
  printf "\nshell aliases and the 'nvims' command have been created for you."
  [ -f "${LMANDIR}"/.lazymanrc ] && source "${LMANDIR}"/.lazymanrc
  if ! alias nvims >/dev/null 2>&1; then
    printf "\nTo activate these aliases and the 'nvims' Neovim config switcher,"
    printf "\nlogout and login or issue the following command:"
    printf "\n\tsource ~/.config/${LAZYMAN}/.lazymanrc"
  fi
  show_alias "${nvimdir[0]}"
}
[ "$quiet" ] || {
  printf "\n\nRun 'lazyman' with no arguments for an interactive menu system\n\n"
}

[ "$tellme" ] || {
  [ "$runvim" ] && {
    [ "$all" ] && export NVIM_APPNAME="$lazymandir"
    nvim
  }
}

[ "$lazyinst" ] && {
  [ "$tellme" ] || {
    [ -d "$HOME"/.local/bin ] || mkdir -p "$HOME"/.local/bin
    [ -f "${LMANDIR}"/lazyman.sh ] && {
      cp "${LMANDIR}"/lazyman.sh "$HOME"/.local/bin/lazyman
      chmod 755 "$HOME"/.local/bin/lazyman
    }
  }
}
[ "$maninst" ] && {
  [ "$tellme" ] || {
    [ -d "$HOME"/.local/share/man ] || mkdir -p "$HOME"/.local/share/man
    [ -d "$HOME"/.local/share/man/man1 ] || mkdir -p "$HOME"/.local/share/man/man1
    [ -f "${LMANDIR}"/man/man1/lazyman.1 ] && {
      cp "${LMANDIR}"/man/man1/lazyman.1 "$HOME"/.local/share/man/man1/lazyman.1
      chmod 644 "$HOME"/.local/share/man/man1/lazyman.1
    }
  }
}

[ "$interactive" ] && show_menu
