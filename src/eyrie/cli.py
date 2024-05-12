import os
from pprint import pprint
import sys

import click
import pexpect

from .conf import settings
from .helpers import run_command


# Define the CLI group
@click.group()
def cli():
    """Simple CLI for managing a project's lifecycle."""
    pass


# Define the "start" command in the CLI group
@cli.command()
@click.argument(
    "which",
    type=click.Choice(["dev", "nothing", "evenmorenothing"], case_sensitive=False),
)
def start(which):
    """Starts tasks based on the specified environment."""
    actions = {
        "dev": "Starting development environment...",
        "nothing": "Starting nothing...",
        "evenmorenothing": "Starting even more nothing...",
    }

    # Execute the action
    click.echo(actions[which.lower()])

    # Example of executing a shell command using Pexpect
    if which.lower() == "dev":
        click.echo("Running development tasks...")
        child = pexpect.spawn("bash", ["-c", "some_long_running_command"])
        child.logfile = sys.stdout.buffer
        child.expect(pexpect.EOF)
    elif which.lower() == "nothing":
        click.echo("Doing essentially nothing...")
    elif which.lower() == "evenmorenothing":
        click.echo("Doing absolutely nothing...")


# Define the "version" command in the CLI group
@cli.command()
def version():
    """Displays the version by executing 'versioningit'."""
    try:
        # Using Pexpect to run versioningit and capture output
        child = pexpect.spawn("versioningit")
        child.expect(pexpect.EOF)
        output = child.before.decode().strip()
        click.echo(output)
    except pexpect.exceptions.ExceptionPexpect as e:
        # Handle errors in Pexpect
        click.echo("Error executing versioningit:", err=True)
        click.echo(str(e), err=True)

    print("And here's some settings...")
    pprint(settings)


# Vagrant commands
@cli.group()
def vagrant():
    """Vagrant-related operations!"""
    pass


@vagrant.command()
@click.argument("command", default="status", required=False)
def cmd(command):
    """Runs a Vagrant command."""
    # Ensure we are in the correct directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    output = run_command(f"vagrant {command}")
    if output:
        click.echo(output)


if __name__ == "__main__":
    cli()
