import pexpect
import os


def run_command(command, expect_end=True, timeout=None):
    """
    Runs a shell command using Pexpect and ensures the command inherits the environment.

    Args:
        command (str): The command to execute.
        expect_end (bool): Whether to wait for EOF or not.
        timeout (int): Timeout for command execution, default is no timeout.

    Returns:
        str: The output of the command if successful, None if an error occurred.
    """
    env = os.environ.copy()  # Copy the current environment
    try:
        child = pexpect.spawn(command, timeout=timeout, env=env)
        if expect_end:
            child.expect(pexpect.EOF)
        output = child.before.decode().strip()
        return output
    except (pexpect.EOF, pexpect.TIMEOUT) as e:
        print(f"Command timeout or unexpected end: {e}")
    except pexpect.exceptions.ExceptionPexpect as e:
        print(f"An error occurred: {e}")
    return None
