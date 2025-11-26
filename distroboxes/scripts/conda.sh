#!/bin/sh

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -C /usr/bin --strip-components=1 -xvj bin/micromamba
