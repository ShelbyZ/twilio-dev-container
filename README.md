# twilio-dev-container

A docker container enabled in VS Code as a [Development Container](https://code.visualstudio.com/docs/remote/containers) focused on developing Twilio with JavaScript and Python.

## What's Inside

Include in the container are the following features:

- Debian Buster environment with Node 10.x
- Global node packages - [twilio-cli](https://github.com/twilio/twilio-cli), [twilio-run](https://github.com/twilio-labs/serverless-toolkit), [create-twilio-function](https://github.com/twilio-labs/create-twilio-function), [eslint](https://github.com/eslint/eslint)
- twilio-cli plugins - [@twilio-labs/plugin-serverless](https://github.com/twilio-labs/plugin-serverless)
- twilio-cli bash autocomplete
- Python - virtualenv, [debugpy](https://github.com/microsoft/debugpy)
- Persist bash history between runs](https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs)
- Root .env file becomes environment variables for the container
- Sample JS / Python scripts using environment variables to query Twilio incoming phone numbers
- VS Code launch.json settings for attaching debugger to Javascript / Python
- VS Code extensions for JavaScript and Python Development
  - [dbaeumer.vscode-eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
  - [visualstudioexptteam.vscodeintellicode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode)
  - [ms-python.python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
  - [ms-python.vscode-pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
- **scratch** folder shared with host system, but not source controlled via git

The following ports are exposed by the container:

- 4040 - ngrok web interface
- 5566 - twilio-run port
- 5858 - node inspector debug port
- 5678 - debugpy debug port

## Getting Started

VS Code documentation provides a handy guide to get started at - [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers). To provide a quick break down you will need to install the following:

- Docker 2.x+ (Windows/macOS) or Docker CE/EE 18.06+
- VS Code
- [Remote Development extension pack](https://aka.ms/vscode-remote/download/extension)

The purpose of this repository is to use VS Code with the extension for Remote Containers and use the new command `Remote-Containers: Open Folder in Container`. This will build and configure an environment with VS Code extensions and settings to do some light development with Twilio in JavaScript/Python and have access to twilio-cli. It is useful to grab account credentials including ACCOUNT_SID and AUTH_TOKEN or API_KEY and API_SECRET.

Code is persisted on the host system so after the container exits it is still available.

## Staying up-to-date

The node packages installed are not targeting specific verisions (excluding sample code) so it is possible to rebuild the container using the Command Palette (F1) via **Remote-Containers: Rebuild Container** which will force a rebuild of the base image.

## Using later Node Versions

To use a node version later than 10.x make changes to the root **Dockerfile** choose a supported tag from dockerhub - https://hub.docker.com/_/node. It is best to stick with Debian distributions (non-slim) or a system using bash as the primary shell.

Dockerfile examples
```
FROM node:12-buster
```
```
FROM current-buster
```

## .env

A **.env.sample** file is provided with sample variables that are used by the samples and twilio-cli:

```
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_API_KEY=
TWILIO_API_SECRET=
```

Create a copy of this file named **.env** and it will be used by the container to provide environment varialbles. Additional values can be provided and used as needed.

## Additional VS Code Configuration

In the `.devcontainer/devcontainer.json` file it is possible to:

- Add additional VS Code extensions via the **extensions** array
- Modify the **settings** property to change [settings.json](https://code.visualstudio.com/docs/getstarted/settings) values

More details can be found at [devcontainer.json reference](https://code.visualstudio.com/docs/remote/devcontainerjson-reference). Any changes made to the devcontainer.json file will require a rebuild of the container image.

## Samples

Samples with debugging hooks have been provided located within the **twilio** folder under language/sample. Debugger setup is handled via launch.json and more information about settings or adding additional configurations can be found at - [Debugging](https://code.visualstudio.com/docs/editor/debugging).

### JavaScript

To get started with the JavaScript sample open or navigate a terminal to **twilio/js/sample** and run `npm install`. The **package.json** contains two npm scripts:

- start - run `hello-container.js`
- debug - run `hello-container.js` and wait for debugger to attach

Using `npm run debug` with **Run** (Ctrl+Shift+D) and selecting **Debug node** should attach VS Code to the running script. **Debug node** can be used to attach to any user written code and more information about debugging with node can be found at - [Debugging Guide](https://nodejs.org/en/docs/guides/debugging-getting-started/).

### Python

To get started with the Python sample open or navigate a terminal to **twilio/python/sample** and run `./setup.sh`. Using `run.sh` with **Run** (Ctrl+Shift+D) and selecting **Debug python** should attach VS Code to the running script. More information about **debugpy** CLI can be found at - [debugpy CLI Usage](https://github.com/microsoft/debugpy#debugpy-cli-usage).


## Errors

It seems to be an issue with symlinks when building the container with the **bin** folder created by virtualenv which may cause an issue when rebuilding a container that does not mask or ignore the folder entirely. The error may look something like:

```
[2020-12-23T17:30:00.153Z] [PID 22092] Building twilio-dev
[2020-12-23T17:30:00.279Z] [PID 22092] Traceback (most recent call last):
  File "site-packages\docker\utils\build.py", line 96, in create_archive
OSError: [Errno 22] Invalid argument: '\\\\?\\y:\\Projects\\twilio-dev-container
\\twilio\\python\\sample\\bin\\python'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "docker-compose", line 3, in <module>
  File "compose\cli\main.py", line 67, in main
  File "compose\cli\main.py", line 126, in perform_command
  File "compose\cli\main.py", line 1070, in up
  File "compose\cli\main.py", line 1066, in up
  File "compose\project.py", line 615, in up
  File "compose\service.py", line 346, in ensure_image_exists
  File "compose\service.py", line 1125, in build
  File "site-packages\docker\api\build.py", line 160, in build
  File "site-packages\docker\utils\build.py", line 31, in tar
  File "site-packages\docker\utils\build.py", line 100, in create_archive
OSError: Can not read file in context: \\?\y:\Projects\twilio-dev-container\twil
io\python\sample\bin\python
[23620] Failed to execute script docker-compose
```

It did not seem possible to control hiding the file via **.dockerignore**. As a workaround it is possible to map **bin** to a docker volume and prevent the files from being accessible during an image build. This can be seen **docker-compose.yml**:

```
services:
    twilio-dev:
        volumes:
            - python-bin:/usr/src/twilio/python/sample/bin

volumes:
    python-bin: # persist local sample python bin
```