#!/usr/bin/env python

# import importlib.resources as resources
import os
from importlib import import_module, resources
from importlib import metadata as pkg_metadata
from logging import getLogger

import click
import pexpect

# from .conf import settings
from .helpers import run_command

log = getLogger(__name__)

PLUGIN_ENTRYPOINT = 'eyrie.plugins'
APPROVED_PLUGINS = ('example_plugin',)


class EyrieContext(click.Context):
    def __init__(self, *args, **kwargs):
        self.debug = False
        super().__init__(*args, **kwargs)


class EyrieCLI(click.Group):
    context_class = EyrieContext

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.debug = False
        self.load_commands()
        self.load_plugins()

    def load_commands(self):
        """
        Load commands from modules (and packages) under `eyrie/commands/`.
        The module's `register` function is called with the base Click CLI group.
        """
        for entry in resources.files('eyrie.commands').iterdir():
            module = None
            if entry.is_file() and entry.suffix == '.py' and entry.stem != '__init__':
                module = import_module(f'eyrie.commands.{entry.stem}')
            elif entry.is_dir() and (entry / '__init__.py').exists():
                module = import_module(f'eyrie.commands.{entry.name}')
            if module and hasattr(module, 'register'):
                log.debug(f"Imported command module '{module.__name__}', registering...")
                module.register(self)

    def load_plugins(self, develop='false'):
        """
        Load plugins from the `eyrie.plugins` entry point.
        """
        development_mode = os.getenv('EYRIE_DEV_MODE', develop).lower() == 'true'

        for entry_point in pkg_metadata.entry_points(group=PLUGIN_ENTRYPOINT):
            if development_mode or entry_point.name in APPROVED_PLUGINS:
                plugin = entry_point.load()
                plugin.init(self)
            else:
                click.echo(
                    f"Plugin '{entry_point.dist.project_name}' is not approved and will not be loaded.",
                    err=True,
                )

    def parse_args(self, ctx, args):
        # Parse global options like --debug here
        if '--debug' in args:
            self.debug = True
            args.remove('--debug')
        super().parse_args(ctx, args)

    def format_help(self, ctx, formatter):
        formatter.write_text('Custom help for the main command!!')
        super().format_help(ctx, formatter)


@click.group(cls=EyrieCLI)
@click.option('--debug', is_flag=True, help='Enable debug mode.')
@click.pass_context
def cli(ctx, debug):
    ctx.debug = debug


# Define the "version" command in the CLI group
@cli.command()
def version():
    """Displays the version by executing 'versioningit'."""
    try:
        # Using Pexpect to run versioningit and capture output
        child = pexpect.spawn('versioningit')
        child.expect(pexpect.EOF)
        output = child.before.decode().strip()
        click.echo(output)
    except pexpect.exceptions.ExceptionPexpect as e:
        # Handle errors in Pexpect
        click.echo('Error executing versioningit:', err=True)
        click.echo(str(e), err=True)


if __name__ == '__main__':
    cli()
