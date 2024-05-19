import os


# def load_command_groups(package_name, callback):
#     """
#     Load command groups from a given package and register them using the provided callback function.

#     Args:
#         package_name (str): The package name to load command groups from.
#         register_callback (function): The callback function to register the command groups.
#     """
#     from importlib import import_module, resources

#     for resource in resources.contents(package_name):
#         # If it's a Python file, under the package
#         if resource.endswith(".py") and resource != "__init__.py":
#             module = import_module(f"{package_name}.{resource[:-3]}")
#             if hasattr(module, "register_group"):
#                 group = module.register_group()
#                 callback(group)
#         # If it's a sub-package within package
#         elif resources.is_resource(package_name, resource) and resources.is_resource(
#             f"{package_name}.{resource}", "__init__.py"
#         ):
#             # Handling sub-packages with __init__.py
#             module_name = f"{package_name}.{resource}"
#             module = import_module(module_name)
#             if hasattr(module, "register_group"):
#                 group = module.register_group()
#                 callback(group)


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
    import pexpect

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
