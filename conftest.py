import pytest
import subprocess
import os
import shutil


@pytest.fixture(scope='session')
def dev_env():
    os.environ['EYRIE_ENV'] = 'development'
    # # Any additional setup, like starting a development server, etc.
    # # For example, installing dependencies for development:
    # subprocess.run(['pip', 'install', '-e', '.'], check=True)
    yield
    # Teardown code if necessary
    os.environ.pop('EYRIE_ENV')


@pytest.fixture(scope='session')
def dist_env(tmp_path_factory):
    # Set up your distribution environment
    os.environ['EYRIE_ENV'] = 'distribution'
    # Create a virtual environment for testing the wheel
    venv_path = tmp_path_factory.mktemp('venv')
    subprocess.run(['python', '-m', 'venv', str(venv_path)], check=True)
    # # Install the wheel
    # subprocess.run(
    #     [str(venv_path / 'bin' / 'pip'), 'install', 'dist/eyrie-0.1-py3-none-any.whl'], check=True
    # )
    yield
    # Teardown code if necessary
    os.environ.pop('EYRIE_ENV')
    shutil.rmtree(venv_path)
