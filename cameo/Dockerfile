FROM dddecaf/wsgi-base:debian

# The sympy cache causes significant memory leaks as it is currently used by
# optlang. Disable it by default.
ENV SYMPY_USE_CACHE=no

# CPLEX is provided externally; see the README
ARG REPO_URL
ARG GITHUB_TOKEN
ARG CPLEX="cplex_128.tar.gz"

# Work in the /opt directory to persist the pip-compiled requirement list for
# child images to use.
WORKDIR /opt

COPY modeling-requirements.in ./

RUN set -eux \
    && pip-compile --generate-hashes \
        --output-file modeling-requirements.txt modeling-requirements.in \
    && pip-sync modeling-requirements.txt

# Install CPLEX.

COPY download_solver.py ./

RUN set -eux \
    && python3 download_solver.py "${CPLEX}" \
    && tar -xzf "${CPLEX}" \
    && pip --no-cache-dir install cplex_128/python/3.6/x86-64_linux \
    && rm -rf cplex_128*
