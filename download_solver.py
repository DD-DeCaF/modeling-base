#!/usr/bin/env python3

import json
import logging
import os
import sys
from os.path import basename
from shutil import copyfileobj
from urllib.error import HTTPError
from urllib.parse import urljoin
from urllib.request import Request, urlopen


LOGGER = logging.getLogger()


def main(url: str, token: str, file_path: str):
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3.raw'
    }
    LOGGER.info("Retrieving repository content.")
    meta_request = Request(urljoin(url, 'contents'), headers=headers)
    meta = json.load(urlopen(meta_request))
    sha = None
    for element in meta:
        if element['path'] == file_path:
            sha = element['sha']
            break
    if sha is None:
        msg = f"'{file_path}' could not be found in the repository."
        LOGGER.critical(msg)
        raise ValueError(msg)
    LOGGER.info("Downloading '%s'.", file_path)
    file_request = Request(urljoin(url, f'git/blobs/{sha}'), headers=headers)
    with urlopen(file_request) as response, \
            open(basename(file_path), 'wb') as out_file:
        copyfileobj(response, out_file)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f'Usage:\n{sys.argv[0]} <file path>')
        sys.exit(2)
    logging.basicConfig(level='INFO', format='[%(levelname)s] %(message)s')
    try:
        main(
            os.environ['REPO_URL'],
            os.environ['GITHUB_TOKEN'],
            sys.argv[1]
        )
    except (ValueError, HTTPError):
        # We choose not to log tracebacks here because they could reveal
        # secrets.
        LOGGER.critical("Failed to retrieve '%s'.", sys.argv[1])
        sys.exit(1)
    else:
        sys.exit(0)
