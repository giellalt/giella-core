#!/usr/bin/env python3

from typing import Iterator
from subprocess import PIPE, run
from multiprocessing import Pool, cpu_count
from functools import partial
import os
import sys
from pathlib import Path


def chunk_lines(max_lines=100) -> Iterator[bytes]:
    chunk = []
    for line in sys.stdin.buffer:
        chunk.append(line.strip())
        if len(chunk) >= max_lines:
            yield b"\n".join(chunk)
            chunk = []
    if chunk:
        yield b"\n".join(chunk)


def make_tokenised_output(input_bytes: bytes, tokeniser: Path) -> str:
    if not tokeniser.is_file():
        raise FileNotFoundError(f"Tokeniser not found at: {tokeniser}")
    command = ["hfst-tokenise", str(tokeniser)]
    result = run(
        command,
        input=input_bytes,
        stdout=PIPE,
        stderr=PIPE,
        check=True,
    )
    return result.stdout.decode("utf-8")


def exit_quietly_on_broken_pipe() -> None:
    # Prevent Python from flushing a broken stdout at interpreter shutdown.
    devnull = os.open(os.devnull, os.O_WRONLY)
    try:
        os.dup2(devnull, sys.stdout.fileno())
    finally:
        os.close(devnull)
    raise SystemExit(0)


def drain_stdin() -> None:
    # Keep consuming input so upstream writers do not fail with BrokenPipe.
    for _ in sys.stdin.buffer:
        pass


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path_to_tokeniser>")
        sys.exit(1)
    tokeniser = Path(sys.argv[1])
    if not tokeniser.is_file():
        drain_stdin()
        print(f"Tokeniser not found at: {tokeniser}")
        sys.exit(1)
    else:
        cpus = cpu_count() - 2 if cpu_count() > 2 else 1
        with Pool(processes=cpus) as pool:
            tokenised_chunks = pool.imap(
                partial(make_tokenised_output, tokeniser=tokeniser),
                chunk_lines(),
                chunksize=1,
            )
            try:
                print("".join(tokenised_chunks))
            except BrokenPipeError:
                exit_quietly_on_broken_pipe()
