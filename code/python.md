# venv

1. we are located in project root folder
2. create a venv folder and a project files folder
3. we leave the venv folder alone and work from project files folder

### create venv [docs](https://docs.python.org/3/library/venv.html)

`python3 -m venv venv`

### if using powershell may require setting execution policy

`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### then activate venv

`.\venv\Scripts\Activate.ps1`

### if using cmd.exe to activate venv

`.\venv\Scripts\activate.bat`

### if using bash on windows to activate venv

`. venv/Scripts/activate`

# localhost web server

`python -m http.server`
defaults to port 8000

# py-launcher

`py -0`
displays all installed python versions

### windows shebangs

shebangs are for \*nix and windows needs py-launcher to mimic that behaviour

https://docs.python.org/3/using/windows.html#shebang-lines

> "The /usr/bin/env form of shebang line has one further special property. Before looking for installed Python interpreters, this form will search the executable PATH for a Python executable"
