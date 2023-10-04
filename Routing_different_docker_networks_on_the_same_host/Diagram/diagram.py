#!/usr/bin/env python3

from diagrams import Cluster, Diagram
from diagrams.onprem.container import Docker

with Diagram("", filename='docker_diagram.png', show=False):

    with Cluster("Docker Host"):
        container01 = Docker("container01\nnet01")
        container02 = Docker("container02\nnet02")
        vyos = Docker("vyos\nnet01     net02")

    container01 >> vyos << container02



