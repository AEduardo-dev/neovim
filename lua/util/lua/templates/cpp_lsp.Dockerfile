FROM gcc:latest as lsp

RUN apt-get update && apt-get install -y \
    cmake \
    clang \
    clang-format \
    clang-tidy \
    cppcheck \
    bear \
    && rm -rf /var/lib/apt/lists/*
