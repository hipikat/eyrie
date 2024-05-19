#!/usr/bin/env python

# import importlib.resources as resources
import os
from importlib import import_module, resources
from importlib import metadata as pkg_metadata
from logging import getLogger
from pathlib import Path

import click

log = getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parent
while PROJECT_ROOT != PROJECT_ROOT.root:
    if (PROJECT_ROOT / 'pyproject.toml').exists():
        break
    PROJECT_ROOT = PROJECT_ROOT.parent

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


# `eyrie version`
@cli.command()
@click.option(
    '--package', 'which', flag_value='package', help='Version according to the package metadata'
)
@click.option(
    '--current',
    'which',
    flag_value='current',
    help='version with last commit hash and dirty flag (default)',
    default=True,
)
@click.option('--next-patch', 'which', flag_value='next-patch', help='Next patch version')
@click.option('--next-minor', 'which', flag_value='next-minor', help='Next minor version')
@click.option('--next-major', 'which', flag_value='next-major', help='Next major version')
@click.option('--write', is_flag=True, help='Write the version to files')
def version(which, write):
    """
    Display the current version of the application. "Current" differs from
    "package" by adding the last commit hash and a 'dirty' flag if there are
    uncommitted changes in the working tree.
    """
    import versioningit

    errout = ''
    version = 'Unknown'
    pkg_version = pkg_metadata.version(__name__.split('.')[0])
    match which:
        case 'package':
            version = pkg_version
        case 'current':
            version = versioningit.get_version(write=write)
            errout += 'Updated project with [tool.versioningit.write] settings\n'
        case 'next-minor':
            version = versioningit.get_next_version()
        case 'next-patch' | 'next-major':
            from semver import VersionInfo

            sem_ver = VersionInfo.parse(pkg_version)
            bump_fn = 'bump_' + which.split('-')[1]
            next_sem_ver = getattr(sem_ver, bump_fn)()
            version = str(next_sem_ver)
        case _:
            breakpoint()

    click.echo(version)

    if write:
        from tomlkit import parse, dumps, document, table

        with open(PROJECT_ROOT / 'pyproject.toml', 'r') as file:
            pyproject_data = parse(file.read())
        pyproject_data['project']['version'] = version
        with open(PROJECT_ROOT / 'pyproject.toml', 'w') as file:
            file.write(dumps(pyproject_data))

        click.echo(errout + f"Wrote version '{version}' to pyproject.toml", err=True)

    return version


if __name__ == '__main__':
    cli()
