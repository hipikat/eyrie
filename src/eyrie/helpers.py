import pexpect
import click


def run_command(command, expect_end=True, timeout=20):
    """
    Runs a shell command using Pexpect and handles outputs and errors.

    Args:
        command (str): The command to execute.
        expect_end (bool): Whether to wait for EOF or not.
        timeout (int): Timeout for command execution, default is no timeout.

    Returns:
        str: The output of the command if successful, None if an error occurred.
    """
    try:
        child = pexpect.spawn(command, timeout=timeout)
        if expect_end:
            child.expect(pexpect.EOF)
        output = child.before.decode().strip()
        return output
    except (pexpect.EOF, pexpect.TIMEOUT) as e:
        click.echo(f"Command timeout or unexpected end: {str(e)}", err=True)
    except pexpect.exceptions.ExceptionPexpect as e:
        click.echo(f"An error occurred: {str(e)}", err=True)
    return None
