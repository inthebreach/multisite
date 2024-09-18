image:
  file: .gitpod.Dockerfile

tasks:
  - name: Install WordPress Multisite
    init: bash ./scripts/install.sh
    command: bash ./scripts/start.sh

ports:
  - port: 80
    onOpen: open-preview
  - port: 3306
    onOpen: ignore

vscode:
  extensions:
    - eg2.vscode-npm-script
    - felixfbecker.php-debug
    - bmewburn.vscode-intelephense-client
    - dbaeumer.vscode-eslint
    - esbenp.prettier-vscode

github:
  prebuilds:
    master: true
    branches: true
    pullRequests: true
    pullRequestsFromForks: true
    addCheck: true
    addComment: true
    addBadge: true
