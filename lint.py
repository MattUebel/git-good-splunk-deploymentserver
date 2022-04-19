import configparser
import os
import sys

VALID_DS = "ds.mattuebel.splunk.net:8089"
ERROR_MESSAGES = []
WARNING_MESSAGES = []
OUTPUT_FILE = "output.txt"

config_files = []
for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".conf"):
            config_files.append(os.path.join(root, file))

for file in config_files:
    config = configparser.ConfigParser()
    config.read(file)
    for section in config.sections():
        if config.has_option(section, "targetUri"):
            ds = config.get(section, "targetUri")
            if ds != VALID_DS:
                ERROR_MESSAGES.append(
                    f"`{file}`:`{section}`: The targetUri of `{ds}` is not the valid Deployment Server : `{VALID_DS}`"
                )

with open(OUTPUT_FILE, "w") as f:
    if ERROR_MESSAGES:
        print(f"::set-output name=status::failure")
        f.write("### Errors :red_circle:\n")
        f.write("\n".join(ERROR_MESSAGES))
    else:
        f.write("### No errors found! :tada:\n")
