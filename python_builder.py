#!/usr/bin/env python
import subprocess

container_archive = subprocess.run(["nix-build", "docker.nix"], capture_output=True)
container_archive = container_archive.stdout.decode('utf-8')[:-1]
capture = subprocess.run(["podman", "load", "-q"], stdin=open(container_archive), capture_output=True)
print(str(capture.stdout))
