#!/bin/sh

useradd --uid 30000 --create-home build
echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen


