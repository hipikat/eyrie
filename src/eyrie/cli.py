import click


# Define the CLI group
@click.group()
def cli():
    """Simple CLI for managing a project's lifecycle."""
    pass


# Define a command in the CLI group
@cli.command()
@click.argument('which',
                type=click.Choice(['dev', 'nothing', 'evenmorenothing'],
                                  case_sensitive=False))
def start(which):
    """Starts tasks based on the specified environment."""
    actions = {
        'dev': "Starting development environment...",
        'nothing': "Starting nothing...",
        'evenmorenothing': "Starting even more nothing..."
    }

    # Execute the action
    click.echo(actions[which.lower()])

    # Example of executing a shell command
    if which.lower() == 'dev':
        click.echo("Running development tasks...")
        # Here you can add actual shell commands, e.g., using os.system() or subprocess.run()
    elif which.lower() == 'nothing':
        click.echo("Doing essentially nothing...")
    elif which.lower() == 'evenmorenothing':
        click.echo("Doing absolutely nothing...")


if __name__ == '__main__':
    cli()
