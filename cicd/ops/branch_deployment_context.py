# This Python script is used to generate a deployment context based on a given context and an instantiation template.

import os
import hcl2
import json
import logging
import argparse
import ops_logging

from jinja2 import Environment, FileSystemLoader

# Logger
logger = logging.getLogger(__name__)

# Helpers
def merge_dicts(original, rendered):
    result = original.copy()
    for key, value in rendered.items():
        if key in result:
            if isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = merge_dicts(result[key], value)
            else:
                result[key] = value
        else:
            result[key] = value
    return result

# This function is used to convert a dictionary to a string similar to the HCL format, althgough it is a very dirty hack due to the lack of a proper HCL encoder.
def dict_to_string(obj, indent=0):
    items = []
    for key, value in obj.items():
        if isinstance(value, dict):
            value_str = dict_to_string(value, indent + 2)
        elif isinstance(value, list):
            value_str = "[\n"
            for item in value:
                value_str += " " * (indent + 4) + str(item) + "\n"
            value_str = value_str[:-2] + "\n" + " " * (indent + 2) + "]"
        elif isinstance(value, bool):
            value_str = str(value).lower()
        elif isinstance(value, str):
            value_str = f'"{value}"'
        else:
            value_str = str(value)

        items.append(f'{" " * (indent + 2)}{key} =  {value_str}')

    return "{\n" + "\n".join(items) + "\n" + " " * indent + "}"

# Command line arguments configuration helper
def _configure_args():
    """
    Configures the command line arguments for the script.
    ./branch_deployment_context.py -t instantiation_template -c source_deployment_context -o new_deployment_context
        Where:
            -t is the instantiation template file
            -c is the source deployment context file
            -o is the output deployment context file
    """
    parser = argparse.ArgumentParser(description='Generates a deployment context based on a given context and an instantiation template.')
    parser.add_argument('-t', '--template', type=str, help='The instantiation template file', required=True)
    parser.add_argument('-c', '--context', type=str, help='The source deployment context file', required=True)
    parser.add_argument('-o', '--output', type=str, help='The output deployment context file', required=True)
    # Help message
    #parser.add_argument('-h', '--help', action='help', default=argparse.SUPPRESS, help='Show this help message and exit.')
    return parser.parse_args()

# Parse the HCL source context file
def get_source_context(source_context_file):
    logger.info(f"Parsing the source context file, '{source_context_file}'")
    try:
        with open(source_context_file, 'r') as f:
            context_data = hcl2.load(f)
        return context_data
    except Exception as e:
        logger.error(f"Failed to parse the source context file, '{source_context_file}' due to '{e}'")
        raise e

# Parse and render the instantiation template
def render_template(path_template_file):
    logger.info(f"Parsing and rendering the template file, '{path_template_file}'")
    # Load the jinja2 template
    try:
        jinja2_env = Environment(loader=FileSystemLoader(os.path.dirname(path_template_file)))
        template = jinja2_env.get_template(os.path.basename(path_template_file))
    except Exception as e:
        logger.error(f"Failed to load the template file, '{path_template_file}' due to '{e}'")
        raise e
    else:
        # Template data
        template_data = {
            "deploymentNamespace": os.environ["BRANCH_NAME"]
        }
        # Render the template
        try:
            return template.render(template_data)
        except Exception as e:
            logger.error(f"Failed to render the template file, '{path_template_file}' due to '{e}'")
            raise e


# Produce the new deployment context
def instantiate_deployment_context(source_context, rendered_template):
    logger.info(f"Instantiating the deployment context")
    try:
        # Load the rendered template
        rendered_template_data = hcl2.loads(rendered_template)
        # Merge the source context and the rendered template
        return merge_dicts(source_context, rendered_template_data)
    except Exception as e:
        logger.error(f"Failed to instantiate the deployment context due to '{e}'")
        raise e

# Write the new deployment context to a file
def write_deployment_context(deployment_context, output_file):
    logger.info(f"Writing the deployment context to the file, '{output_file}'")
    try:
        with open(output_file, 'w') as f:
            #f.write(json.dumps(deployment_context, indent=4, ))
            f.write(dict_to_string(deployment_context)[1:-1])
    except Exception as e:
        logger.error(f"Failed to write the deployment context to the file, '{output_file}' due to '{e}'")
        raise e


# Instantiate 


# Main
if __name__ == "__main__":
    # Configure and parse the command line arguments
    args = _configure_args()
    # Get the source context
    source_context = get_source_context(args.context)
    # Render the template
    rendered_template = render_template(args.template)
    # Instantiate the deployment context
    deployment_context = instantiate_deployment_context(source_context, rendered_template)
    # Write the deployment context to a file
    write_deployment_context(deployment_context, args.output)