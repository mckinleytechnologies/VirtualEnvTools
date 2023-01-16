# VirtualEnvTools

## To Use:
- Clone the repo
- Import the module using:

    `Import-Module {path to repo}\VirtualEnvTools.psm1`

    You will see a warning about unapproved verbs. This can be disabled by importing the module with the `-DisableNameChecking` parameter:

    `Import-Module {path to repo}\VirtualEnvTools.psm1 -DisableNameChecking`
- Set the `VENVROOT` environment variable
    - This is the root path for all your python virtual environments

        The VirtualEnvTools commands currently only work with a single VENVROOT location

## Commands
There are two available commands:
- `List-VirtualEnvs`: This lists all the virtual environments found under `VENVROOT`
- `Activate-VirtualEnv {venv name}`: This calls the `Activate.ps1` script for the specified virtual environment.
    - The `{venv name}` is the name of the virtual environment, i.e., the name of the folder under `VENVROOT`
