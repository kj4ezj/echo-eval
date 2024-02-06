# echo-eval
This library simply prints a bash command with a shell prompt in front of it and then runs that command using `eval`. This pattern makes your shell scripts easier to debug because you can see which commands are being run and what the output is in a way that is familiar and approachable to you and your customers.

### Index
1. [Background](#background)
1. [Installation](#installation)
    1. [bpkg](#bpkg) - package manager
    1. [make](#make)
    1. [Manual Installation](#manual-installation)
1. [Usage](#usage)
1. [Development](#development)
    1. [Dependencies](#dependencies)
    1. [Lint](#lint)
    1. [Test](#test)

## Background
The name comes from a syntax I have used in BASH scripts to print significant or complex commands before running them to provide insight into what a script is doing for more technical users and customers, or for debugging.
```bash
echo "$ ls -la ~"
eval "ls -la ~"
```
The commands are displayed in the terminal in a way that looks like shell history, as if a human had sat at the terminal, typed the command, and run it.
```
$ ls -la
total 56
drwxr-xr-x   1 root root 4096 Feb 27 20:01 .
drwxr-xr-x   1 root root 4096 Feb 27 20:01 ..
lrwxrwxrwx   1 root root    7 Jan 13 16:47 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 15  2020 boot
drwxr-xr-x   5 root root  360 Feb 27 20:01 dev
drwxr-xr-x   1 root root 4096 Feb 27 20:01 etc
drwxr-xr-x   2 root root 4096 Apr 15  2020 home
lrwxrwxrwx   1 root root    7 Jan 13 16:47 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Jan 13 16:47 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Jan 13 16:47 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Jan 13 16:47 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Jan 13 16:47 media
drwxr-xr-x   2 root root 4096 Jan 13 16:47 mnt
drwxr-xr-x   2 root root 4096 Jan 13 16:47 opt
dr-xr-xr-x 481 root root    0 Feb 27 20:01 proc
drwx------   2 root root 4096 Jan 13 16:50 root
drwxr-xr-x   5 root root 4096 Jan 13 16:50 run
lrwxrwxrwx   1 root root    8 Jan 13 16:47 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Jan 13 16:47 srv
dr-xr-xr-x  13 root root    0 Feb 27 20:01 sys
drwxrwxrwt   2 root root 4096 Jan 13 16:50 tmp
drwxr-xr-x  13 root root 4096 Jan 13 16:47 usr
drwxr-xr-x  11 root root 4096 Jan 13 16:50 var
```
I find this is much more approachable to newer developers than something like `set -x`, which displays a bunch of nonsense in addition to the commands being run on most systems.

The logical next step was to de-duplicate the command so what is printed could never be different than what is being run.
```bash
DOCKER_RUN='docker run -it ubuntu:20:04'
echo "$ $DOCKER_RUN"
eval "$DOCKER_RUN"
```
This is a pain to type for all the major commands a script is doing and makes the source file thrice as many lines long.

The solution to this toil was to de-duplicate the pattern itself using a BASH function so that commands only take one line each again.
```bash
ee 'docker run -it ubuntu:20:04'
```
Finally, the function has been packaged as a module that can be installed on a system or imported by BASH scripts using a package manager.

## Installation
You can install this script using a package manager (recommended), install manually and source it from somewhere, or invoke it directly without installing.

### bpkg
This is the recommended installation method. Install [bpkg](https://github.com/bpkg/bpkg) if you have not already. Then, you have three installation options.
1. Install as a dependency for your BASH script. From the root of your project repo:
    ```bash
    bpkg install kj4ezj/echo-eval
    ```
    This will create a `deps/` folder in the current directory with the following structure.
    ```
    deps
    ├── bin
    │   └── ee -> /deps/echo-eval/ee.sh
    └── echo-eval
        ├── bpkg.json
        └── ee.sh
    ```
    You can source one or more dependencies in your script from `./deps/bin/`.
    - Be sure to add `deps` to your `.gitignore`.
    - If you package your project, be sure to declare this as a dependency in your `bpkg.json` file.
1. Install globally for the current user.
    ```bash
    bpkg install -g kj4ezj/echo-eval
    ```
1. Install globally for all users on the current system.
    ```bash
    sudo bpkg install -g kj4ezj/echo-eval
    ```

> [!NOTE]
> At the time of writing, [`bpkg` does not have a global uninstall](https://github.com/bpkg/bpkg/issues/31). You can uninstall by deleting the relevant executable.
> ```bash
> EE_PATH="$(which ee || ee 'echo "${BASH_SOURCE[0]}"' | tail -1)"
> rm -f "$EE_PATH" 2>/dev/null || sudo rm -f "$EE_PATH"
> ```

### make
Clone this repo locally using your preferred method. Navigate to the root of the repo in your termial and install.
```bash
sudo make install
```
This will install `ee` for all users. If you do not wish to use `sudo` or otherwise install using `root` permissions, please [install using `bpkg`](#bpkg).

Do the reverse to uninstall. From the root of this repo in your terminal:
```bash
sudo make uninstall
```

### Manual Installation
You can also source this script in your `~/.bashrc` or similar.
```bash
source ~/github/kj4ezj/echo-eval/ee.sh
```
Just remove that line to "uninstall."

## Usage
This library performs the `echo`/`eval` pattern against any string(s) passed to `ee`. For example, the output of...
```bash
ee jq --version
```
...might look like:
```
$ jq --version
jq-1.6
```

You can invoke `ee` as a function...
```bash
echo-eval$ ee echo test
$ echo test
test
```
...or as a file.
```bash
echo-eval$ ./ee.sh echo test
$ echo test
test
```

Some more complicated commands may need to be encased in quotes, such as this command where we are using pipes but wish to echo the entire command.
```bash
echo-eval$ export EXAMPLE='yeet'
echo-eval$ ee printf "$EXAMPLE" | wc -c
18
echo-eval$ ee 'printf "$EXAMPLE" | wc -c'
$ printf "$EXAMPLE" | wc -c
4
```
Here, you can see one intending to print the length of the value of the `EXAMPLE` environment variable only got the expected output when the whole command was surrounded in single quotes. Be vigilant of quoting, especially if variables being consumed by commands contain secrets and you want `ee` to print the _name_ of the variable in the `echo` step, not the _value_ contained by the variable. It is recommended you always try out commands locally in your shell before publishing them.

## Development
Contribute to this project.

### Dependencies
The script itself has no dependencies by design, but you will need these tools to work on this script and test your changes:
- [bashate](https://github.com/openstack/bashate)
- [bats](https://github.com/bats-core/bats-core)
- [bpkg](https://github.com/bpkg/bpkg)
- git
- make
- [shellcheck](https://github.com/koalaman/shellcheck)

### Lint
This project uses [bashate](https://github.com/openstack/bashate) _and_ [shellcheck](https://github.com/koalaman/shellcheck) for linting.
```bash
shellcheck -x -f gcc ee.sh ee.test.bats
bashate -i E006 ee.sh
bashate -i E006,E040 ee.test.bats
```
There is a `bpkg` command if you prefer.
```bash
bpkg run lint
```
This alias is equivalent to the commands above.

### Test
This project uses the [BASH Automated Testing System](https://github.com/bats-core/bats-core) (BATS). Various issues currently prevent `bpkg` from installing BATS as a dependency in this repo, so you need to install it on your system for now.
```bash
./ee.test.bats
```
There is also a `bpkg` alias.
```bash
bpkg run test
```
This is equivalent to the above.
