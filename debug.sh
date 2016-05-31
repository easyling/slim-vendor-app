#!/usr/bin/env bash

PUB="/usr/lib/dart/bin/pub"

cd client && $PUB serve web --hostname 0.0.0.0 --port 7777 &
cd server && export DART_PUB_SERVE="http://localhost:7777" && $PUB run bin/server.dart