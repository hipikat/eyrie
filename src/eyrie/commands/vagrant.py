import os
import click


# Vagrant commands
@click.group()
def vagrant():
    """Vagrant-related operations!"""
    pass


@vagrant.command()
@click.argument('command', default='status', required=False)
def cmd(command):
    """Runs a Vagrant command."""
    # Ensure we are in the correct directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    output = run_command(f'vagrant {command}')
    if output:
        click.echo(output)


def register(cli):
    cli.add_command(vagrant)
