#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CACHE_DIR="$DIR/.cache"

_log() { echo "=> LOG: $@" 1>&2; }

_error() {
  _log "ERROR: $1"
  exit 1
}

_pushd() {
  pushd "$1" > /dev/null
}
_popd() {
  popd > /dev/null
}

_main() {
  if [ -z "$1" ]; then
    _error "Must pass sd card device!"
  fi

  SHA256="a50237c2f718bd8d806b96df5b9d2174ce8b789eda1f03434ed2213bbca6c6ff"
  mkdir -p "$CACHE_DIR"

  _zip_name="raspbian-buster-lite.zip"
  DOWNLOAD_URL="https://downloads.raspberrypi.org/raspbian_lite_latest"
  _zip="$CACHE_DIR/$_zip_name"

  if [ -f "$_zip" ]; then
    _log "found $_zip"
  else
    _log "downloading $DOWNLOAD_URL"
    curl -L --output "$_zip" "$DOWNLOAD_URL"
  fi
  _pushd "$CACHE_DIR"
  _log "checking $_zip sha256 ($SHA256)"
  if ! echo "$SHA256  $_zip_name"  | sha256sum --check > /dev/null; then
    rm -i $_zip*
  fi
  _popd
  _log "Check OK."

  # todo: this will change at some point
  _IMG="$CACHE_DIR/2019-09-26-raspbian-buster-lite.img"
  _log "\$_IMG=$_IMG"
  if [ -f "$_IMG" ]; then
    _log "Already unzipped"
  else
    _log "unzipping"
    unzip -d "$CACHE_DIR" "$_zip"
  fi

  _log "To write: $_IMG to $1"

  sudo dd status=progress bs=4M if=$_IMG of=$1 conv=fsync

  _mnt_dir="/mnt/rasbpi"
  _log "making mount dir"
  sudo mkdir "$_mnt_dir"
  _log "mounting sdcard"
  sudo mount "$1p1" "$_mnt_dir"
  _log "touching ssh file"
  sudo touch "$_mnt_dir/ssh"
  _log "unmounting"
  sudo umount "$1p1"
  _log "removing mount dir"
  sudo rmdir "$_mnt_dir"

}

_main "$@"
