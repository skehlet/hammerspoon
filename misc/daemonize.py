#!/usr/bin/env python3

import os
import sys


def daemonize(cmd, args):
    # Fork a new child process
    pid = os.fork()
    if pid > 0:
        # Exit the parent process
        os._exit(0)

    # setsid
    os.setsid()

    # double fork to avoid any possibility of reacquiring a controlling terminal
    pid = os.fork()
    if pid > 0:
        # Exit the parent process
        os._exit(0)

    # print(f"pid: {os.getpid()}, ppid: {os.getppid()}, pgid: {os.getpgid(0)}, session id: {os.getsid(0)}")

    # close stdin
    os.close(0)

    # Open /dev/null for writing
    with open("/dev/null", "w", encoding="utf-8") as dev_null:
        # then redirect stdout and stderr to /dev/null
        os.dup2(dev_null.fileno(), 1)
        os.dup2(dev_null.fileno(), 2)

    # Set the working directory to root
    os.chdir("/")

    # Set the umask to 0
    os.umask(0)

    # Exec the program
    os.execvp(cmd, args)


if __name__ == "__main__":
    # Call the daemonize function with the provided command and arguments from sys.argv
    # Example: python daemon.py arg1 arg2 arg3
    #          argv[0]          argv[1]    argv[2]
    daemonize(sys.argv[1], sys.argv[1:])
