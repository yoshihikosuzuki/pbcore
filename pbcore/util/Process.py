

__doc__="""Useful functions for interacting with processes."""
import sys
import os
import subprocess

def backticks( cmd, merge_stderr=True ):
    """
    Simulates the perl backticks (``) command with error-handling support
    Returns ( command output as sequence of strings, error code, error message )
    """
    if merge_stderr:
        _stderr = subprocess.STDOUT
    else:
        _stderr = subprocess.PIPE

    p = subprocess.Popen( cmd, shell=True, stdin=subprocess.PIPE,
                          stdout=subprocess.PIPE, stderr=_stderr,
                          close_fds=True )

    out = [ l[:-1] for l in p.stdout.readlines() ]

    p.stdout.close()
    if not merge_stderr:
        p.stderr.close()

    # need to allow process to terminate
    p.wait()

    errCode = p.returncode and p.returncode or 0
    if p.returncode>0:
        errorMessage = os.linesep.join(out)
        output = []
    else:
        errorMessage = ''
        output = out

    return output, errCode, errorMessage

