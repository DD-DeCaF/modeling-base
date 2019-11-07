FROM gcr.io/dd-decaf-cfbf6/modeling-base:master

RUN set -eux \
    # Install build tools. These can be required for the `pip-compile` step in
    # child images that require to build packages from source.
    && apt-get update \
    && apt-get install --yes build-essential \
    # Re-run pip-compile in order to pre-populate the pip cache.
    && pip-compile --generate-hashes --output-file /dev/null \
      /opt/modeling-requirements.txt \
    # Clean up to reduce layer size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
