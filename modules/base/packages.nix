{ pkgs, ... }:
{
  # 共有系统包
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # core tools
    # nushell # nushell
    fastfetch # 显示系统图标、版本、主题等信息
    helix # EDITOR `hx`
    # neovim # backup editor; `nvim --clean` for sensitive / privileged edits (`$SUDO_EDITOR`)
    msedit # backup editor `edit`;
    # gnumake # Makefile
    just # a command runner like gnumake, but simpler
    git # used by nix flakes
    # git-lfs # used by huggingface models

    # editor
    vim

    # system monitoring
    procs # a moreden ps
    btop

    # Archive
    xz
    unzip
    zip
    unzipNLS
    p7zip
    zstd

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    gawk # GNU awk, a pattern scanning and processing language
    gnutar
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    sad # CLI search and replace, just like sed, but with diff preview.

    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    jc # converts the output of popular cli tools & file-types to JSON, YAML

    # Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf
    # search for files by name, faster than find
    fd
    findutils
    # search for files by its content, replacement of grep
    (ripgrep.override { withPCRE2 = true; })

    duf # Disk Usage/Free Utility - a better 'df' alternative
    dust # A more intuitive version of `du` in rust
    gdu # disk usage analyzer(replacement of `du`)
    ncdu # analyzer your disk usage Interactively, via TUI(replacement of `du`)

    # networking tools
    mtr # A network diagnostic tool(traceroute)
    gping # ping, but with a graph(TUI)
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    doggo # DNS client for humans
    wget
    curl
    curlie # curl with httpie
    httpie
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
    iperf3 # network performance test
    hyperfine # command-line benchmarking tool
    tcpdump # network sniffer

    # file transfer
    rsync
    croc # File transfer between computers securely and easily

    # security
    libargon2
    openssl

    # misc
    which
    tree # dir tree
    file # file check

    tealdeer # a very fast version of tldr
    udiskie # Automounter for removable media
    git

    # ---
    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # ebpf related tools
    # https://github.com/bpftrace/bpftrace
    bpftrace # powerful tracing tool
    bpftop # monitor BPF programs
    bpfmon # BPF based visual packet rate monitor

    # system monitoring
    sysstat
    iotop-c
    iftop
    nmon
    sysbench
    systemctl-tui
    pv # pipe view

    # system tools
    psmisc # killall/pstree/prtstat/fuser/...
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    hdparm # for disk performance, command
    dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
    parted
    smartmontools # smartctl -a /dev/nvme0n1
    nvme-cli
  ];

  # BCC - Tools for BPF-based Linux IO analysis, networking, monitoring, and more
  # https://github.com/iovisor/bcc
  programs.bcc.enable = true;
}
