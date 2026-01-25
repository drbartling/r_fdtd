default:
    @just --list

[linux]
install-r:
    sudo apt update
    sudo apt install -y r-base

[macos]
install-r:
    brew install r

[windows]
install-r:
    choco install -y r.project
