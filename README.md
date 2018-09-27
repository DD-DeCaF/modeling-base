# modeling-base

[![master Build Status](https://travis-ci.org/DD-DeCaF/modeling-base.svg?branch=master)](https://travis-ci.org/DD-DeCaF/modeling-base)

A base Docker image for our modeling needs. Contains the relevant Python 
packages, e.g., cobra and cameo, as well as chosen solvers, i.e., at the 
moment GLPK and CPLEX.

## Environment

The following environment variables **must** be defined in the **Travis settings**.

| Variable | Description |
|----------|-------------|
| `REPO_URL` | URL of the private repository storing proprietary solvers. |
| `GITHUB_TOKEN` | A GitHub access token (which should have `repo` permissions only) in order to download proprietary solvers. |
| `DOCKER_PASSWORD` | The Docker Hub password for the `decaftravis` user. |
| `GCLOUD_EMAIL` | The Google Cloud e-mail for the Travis service account. |
| `GCLOUD_KEY` | The Google Cloud key. |

## Development

Type `make` to see frequently used workflow commands. Also take a look at the
 `.travis.yml` configuration to get an idea of the general workflow.

### Testing

* To test all dependencies for vulnerabilities run `make safety`.

## Future

Ideas for future improvements:

* Make the installation of various solvers optional.
* Have one base image with the solvers and optlang.
* Layer different images on top of the base image, for example, cobra only, 
  cobra & cameo, add further visualization packages.
