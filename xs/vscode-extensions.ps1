# transfer vscode setup between windows systems
# from:
# https://www.codeproject.com/Tips/4121672/How-to-Export-VS-Code-Extensions-to-Another-Comput

# copy across settings.json and keybindings.json from:
cd "C:\Users\<username>\AppData\Roaming\Code\User"

# run this powershell command on computer-1 to generate the list below:
code --list-extensions | ForEach-Object { "code --install-extension $_" } > extensions.ps1

# run desired extensions on computer-2
code --install-extension canadaduane.notes
code --install-extension CoenraadS.bracket-pair-colorizer
code --install-extension esbenp.prettier-vscode
code --install-extension GrapeCity.gc-excelviewer
code --install-extension henryclayton.context-menu-toggle-comments
code --install-extension mechatroner.rainbow-csv
code --install-extension ms-vscode.powershell
# web-oriented:
code --install-extension formulahendry.auto-rename-tag
code --install-extension ritwickdey.LiveServer
code --install-extension firefox-devtools.vscode-firefox-debug
code --install-extension whtouche.vscode-js-console-utils
code --install-extension dbaeumer.vscode-eslint
code --install-extension ecmel.vscode-html-css
