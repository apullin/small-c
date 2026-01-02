#!/bin/sh
set -e

usage() {
	echo "Usage: $0 [-o output.asm] input.c [input2.c ...]" >&2
	echo "Env: SMALLC_CTEXT=n|y, SMALLC_GLBS=n|y, SMALLC_LABEL=number" >&2
	exit 2
}

out=""
inputs=""

while [ "$#" -gt 0 ]; do
	case "$1" in
		-o)
			shift
			[ "$#" -gt 0 ] || usage
			out="$1"
			;;
		-c)
			# Accepted for gcc-like feel; no effect for small-c.
			;;
		-h|--help)
			usage
			;;
		--)
			shift
			break
			;;
		-*)
			echo "Unknown option: $1" >&2
			usage
			;;
		*)
			if [ -z "$inputs" ]; then
				inputs="$1"
			else
				inputs="${inputs}
$1"
			fi
			;;
	esac
	shift
done

if [ -z "$inputs" ]; then
	usage
fi

if [ -z "$out" ]; then
	first_input=$(printf "%s\n" "$inputs" | sed -n '1p')
	base=$(basename "$first_input")
	out="${base%.*}.asm"
fi

ctext="${SMALLC_CTEXT:-n}"
glbs="${SMALLC_GLBS:-y}"
label="${SMALLC_LABEL:-0}"

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
compiler="$script_dir/small-c-gcc"

if [ ! -x "$compiler" ]; then
	echo "Compiler not found or not executable: $compiler" >&2
	exit 1
fi

out_dir=$(dirname "$out")
if [ -n "$out_dir" ] && [ "$out_dir" != "." ]; then
	mkdir -p "$out_dir"
fi

{
	printf "%s\n" "$ctext"
	printf "%s\n" "$glbs"
	printf "%s\n" "$label"
	printf "%s\n" "$out"
	printf "%s\n" "$inputs"
	printf "\n"
} | "$compiler"
