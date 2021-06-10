import argparse
import os
from typing import List


def str2bool(v):
    if v.lower() in ("yes", "true", "t", "y", "1"):
        return True
    elif v.lower() in ("no", "false", "f", "n", "0"):
        return False
    else:
        raise argparse.ArgumentTypeError("Unsupported value encountered.")


def parse_args(args: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--arg0", type=str2bool, default=True, help="""Args0."""
    )
    parser.add_argument(
        "--prefix-arg1", type=str2bool, default=True, help="""Args1."""
    )
    return parser.parse_args()


def run(argv: List[str]) -> None:  # noqa: C901
    args = parse_args(argv[1:])

    print(args.arg0)
    print(args.prefix_arg1)


if __name__ == "__main__":
    run(os.sys.argv)
