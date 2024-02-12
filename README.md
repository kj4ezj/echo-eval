# echo-eval
This library simply prints a bash command with a shell prompt in front of it and then runs that command using `eval`. This pattern makes your shell scripts easier to debug because you can see which commands are being run and what the output is in a way that is familiar and approachable to you and your customers.

### Index
1. [Background](#background)
1. [Installation](#installation)
    1. [bpkg](#bpkg) - package manager
    1. [make](#make)
    1. [Manual Installation](#manual-installation)
1. [Usage](#usage)
    1. [Security](#security)
1. [Development](#development)
    1. [Dependencies](#dependencies)
    1. [Lint](#lint)
    1. [Test](#test)
1. [CI](#ci)

## Background
The name comes from a syntax I have used in BASH scripts to print significant or complex commands before running them to provide insight into what a script is doing for more technical users and customers, or for debugging.
```bash
echo "$ ls -la"
eval "ls -la"
```
The commands are displayed in the terminal in a way that looks like shell history, as if a human had sat at the terminal, typed the command, and run it.
```
$ ls -la
total 60
drwxrwxr-x 4 zach zach  4096 Feb  6 10:42 .
drwxrwxr-x 6 zach zach  4096 Feb  1 18:55 ..
-rw-rw-r-- 1 zach zach   563 Feb  6 01:31 bpkg.json
-rwxrwxr-x 1 zach zach   303 Feb  6 10:59 ee.sh
-rwxrwxr-x 1 zach zach 11824 Feb  6 10:44 ee.test.bats
drwxrwxr-x 8 zach zach  4096 Feb  6 10:59 .git
drwxrwxr-x 3 zach zach  4096 Feb  6 01:31 .github
-rw-rw-r-- 1 zach zach   358 Feb  5 21:05 .gitignore
-rw-rw-r-- 1 zach zach  1068 Feb  1 18:55 LICENSE
-rw-rw-r-- 1 zach zach   455 Feb  6 01:34 Makefile
-rw-rw-r-- 1 zach zach  8647 Feb  6 11:23 README.md
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
Clone this repo locally using your preferred method. Navigate to the root of the repo in your terminal and install.
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
This library takes the input you give it, prints or echoes it to the terminal with a fake shell prompt in front of it, then tries to run it as a command. For example, the output of this...
```bash
ee uname
```
...looks like this on Linux.
```
$ uname
Linux
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
Some commands may need to be encased in quotes to work the way you intend. For example, `dc` is sensitive to whitespace.
```bash
echo-eval$ ./ee.sh dc -e '1 2 + p'
$ dc -e 1 2 + p
dc: Could not open file 2
dc: Could not open file +
dc: Could not open file p
echo-eval$ ./ee.sh "dc -e '1 2 + p'"
$ dc -e '1 2 + p'
3
```
In this example, we want the input to `ee` to include the pipe (`|`).
```bash
echo-eval$ export EXAMPLE='yeet'
echo-eval$ ee printf "$EXAMPLE" | wc -c
18
```
BASH evaluated `"$EXAMPLE"`, invoked `ee` with the input `printf yeet`, `ee` returned this...
```
$ printf yeet
yeet
```
...then BASH piped both those lines to `wc -c`, giving eighteen characters. Instead, we want to put quotes around the entire command.
```bash
echo-eval$ ./ee.sh 'printf "$EXAMPLE" | wc -c'
$ printf "$EXAMPLE" | wc -c
4
```
Here, "$EXAMPLE" is evaluated at runtime inside the library and we get the correct output of four characters.

### Security
When you evoke echo-eval (`ee`) from a script or program, it:
1. Inherits the privileges of your script or program.
1. Runs in the context of your script or program.
1. Takes the input as a string and parses it, looking for commands to run.

This means you need to be wary of command injection, variable manipulation, and privilege escalation. _Never_, **_ever_** pass unsanitized user input to echo-eval, even if it is inside a print statement or in single quotes! All attack vectors associated with the `eval` command apply, known and unknown. You have been warned.

## Development
Here is what you need to know to contribute to this project.

### Dependencies
The script itself has no dependencies by design, but you will need these tools to work on this script and test your changes:
- [act](https://github.com/nektos/act)
    - Requires docker.
- [bashate](https://github.com/openstack/bashate)
- [bats](https://github.com/bats-core/bats-core)
- [bpkg](https://github.com/bpkg/bpkg)
    - git
    - make
- [dc](https://www.gnu.org/software/bc/manual/dc-1.05/html_mono/dc.html)
- [git](https://git-scm.com)
- [shellcheck](https://github.com/koalaman/shellcheck)

### Lint
This project uses [bashate](https://github.com/openstack/bashate) _and_ [shellcheck](https://github.com/koalaman/shellcheck) for linting. You can run the lint script directly...
```bash
./lint.sh
```
...or run the linters with `bpkg`.
```bash
bpkg run lint
```
They both do the same thing.

### Test
This project uses the [BASH Automated Testing System](https://github.com/bats-core/bats-core) (BATS). Various issues currently prevent `bpkg` from installing BATS as a dependency, so you need to install it on your system for now.

This project has two [types of tests](https://testing.googleblog.com/2010/12/test-sizes.html):
- `ee.test.bats` - small and medium tests
- `large-test.bats` - large tests

The small tests can be invoked directly...
```bash
./ee.test.bats
```
...or you can run them with `bpkg`.
```bash
bpkg run test
```
The `bpkg` alias calls `test.sh`, which runs the small tests every time and will run the large tests if it detects a cloud-based CI environment. The large tests try to install the current commit from GitHub using `bpkg`, so you won't ever run them locally.

## CI
This repo contains the following GitHub Actions workflow(s) for CI:
- echo-eval CI - initialize, lint, and test the `echo-eval` project.
    - [Pipeline](https://github.com/kj4ezj/echo-eval/actions/workflows/ci.yml)
    - [Documentation](./.github/workflows/README.md)

You can run the GitHub Actions workflow(s) locally using [act](https://github.com/nektos/act).
```bash
act --artifact-server-path .github/artifacts
```
This, too, has a `bpkg` alias so nobody has to memorize it.
```bash
bpkg run act
```
Please make sure pipeline changes do not break `act` compatibility.


***
> **_Legal Notice_**
> This repo contains assets created in collaboration with a large language model, machine learning algorithm, or weak artificial intelligence (AI). This notice is required in some countries.
