#!/bin/bash

export PHP_VERSION=$1

docker build --build-arg PHP_VERSION=${PHP_VERSION} .
