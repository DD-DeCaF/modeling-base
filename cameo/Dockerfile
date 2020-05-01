# Copyright 2018-2020 Novo Nordisk Foundation Center for Biosustainability,
# Technical University of Denmark.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG BASE_TAG=debian

FROM dddecaf/wsgi-base:${BASE_TAG}

# The sympy cache causes significant memory leaks as it is currently used by
# optlang. We disable it by default.
ENV SYMPY_USE_CACHE=no

ARG BASE_TAG=debian
ARG BUILD_COMMIT
ARG BUILD_TIMESTAMP

LABEL dk.dtu.biosustain.modeling-base.cameo.vendor="Novo Nordisk Foundation \
Center for Biosustainability, Technical University of Denmark"
LABEL maintainer="niso@biosustain.dtu.dk"
LABEL dk.dtu.biosustain.modeling-base.cameo.build.base-tag="${BASE_TAG}"
LABEL dk.dtu.biosustain.modeling-base.cameo.build.commit="${BUILD_COMMIT}"
LABEL dk.dtu.biosustain.modeling-base.cameo.build.timestamp="${BUILD_TIMESTAMP}"

WORKDIR /opt

# CPLEX is provided externally; see the README.
ARG CPLEX

ADD "${CPLEX}" ./cplex

COPY modeling-requirements.in ./

RUN set -eux \
    # Compile all the modeling requirements. Note that `pip-compile` will use
    # the local installation of cplex.
    && pip-compile --allow-unsafe --generate-hashes --verbose \
        --output-file modeling-requirements.txt modeling-requirements.in \
    # Pre-install the compiled requirements to save some build time for child
    # images.
    && pip install --require-hashes -r modeling-requirements.txt \
    # Install CPLEX from the external source, after dependency compilation.
    # This means child images can only use `pip install` not `pip-sync`!
    && pip --no-cache-dir install "$(find ./cplex -type d -name x86-64_linux)" \
    && rm -rf ./cplex \
    # Delete the pip cache to minimize image size.
    && rm -rf /root/.cache
