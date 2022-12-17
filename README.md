# echo-eval
This library simply prints a bash command with a shell prompt in front of it and then runs that command using `eval`. This pattern makes your shell scripts easier to debug because you can see which commands are being run and what the output is in a way that is familiar and approachable to you and your customers.

### Index
1. [Background](#background)
1. [Installation](#installation)
    1. [Local Scripts](#local-scripts)
    1. [Shared Scripts](#shared-scripts)
1. [Usage](#usage)

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

### Local Scripts
Make a folder for these types of things to live, if you don't have one already.
```bash
mkdir -p ~/.bash
cd ~/.bash
```
Follow the instructions at the top-right of this repo to use your preferred method to clone this repo into that folder.
```bash
git clone --recursive git@github.com:kj4ezj/echo-eval.git
```
Then, source `ee.sh` in your `~/bashrc`, `~/bash_aliases`, `~/bash_profile`, script, or similar.
```bash
source ~/.bash/echo-eval/ee.sh
```
Finally, reload or restart your shell to use this function in your scripts.

### Shared Scripts
For scripts shared privately or publicly, the "correct" thing to do would be for me to publish this function using a package manager like [`bpkg`](https://github.com/bpkg/bpkg), then for you to import it using a specific semantic version. For now, unfortunatly, I have not gotten around to this yet so I recommend importing this code as a submodule in your BASH script repo.

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
