#!/bin/sh
set -eu

: "${SYNCPLAY_PORT:=8999}"
: "${SYNCPLAY_INTERFACE_IPV4:=127.0.0.1}"

set -- "$@" \
  "--port" "${SYNCPLAY_PORT}" \
  "--interface-ipv4" "${SYNCPLAY_INTERFACE_IPV4}"

if [ -n "${SYNCPLAY_INTERFACE_IPV6:-}" ]; then
  set -- "$@" --interface-ipv6 "${SYNCPLAY_INTERFACE_IPV6}"
fi

if [ "${SYNCPLAY_ISOLATE_ROOM:-false}" = "true" ]; then
  set -- "$@" --isolate-room
fi

if [ "${SYNCPLAY_DISABLE_READY:-false}" = "true" ]; then
  set -- "$@" --disable-ready
fi

if [ "${SYNCPLAY_DISABLE_CHAT:-false}" = "true" ]; then
  set -- "$@" --disable-chat
fi

if [ -n "${SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH:-}" ]; then
  set -- "$@" --max-chat-message-length "${SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH}"
fi

if [ -n "${SYNCPLAY_MAX_USERNAME_LENGTH:-}" ]; then
  set -- "$@" --max-username-length "${SYNCPLAY_MAX_USERNAME_LENGTH}"
fi

if [ -n "${SYNCPLAY_MOTD_FILE:-}" ]; then
  set -- "$@" --motd-file "${SYNCPLAY_MOTD_FILE}"
fi

if [ -n "${SYNCPLAY_STATS_DB_FILE:-}" ]; then
  set -- "$@" --stats-db-file "${SYNCPLAY_STATS_DB_FILE}"
fi

if [ -n "${SYNCPLAY_PASSWORD:-}" ]; then
  export SYNCPLAY_PASSWORD
fi

if [ -n "${SYNCPLAY_SALT:-}" ]; then
  export SYNCPLAY_SALT
fi

if [ -n "${SYNCPLAY_TLS_PATH:-}" ]; then
  set -- "$@" --tls "${SYNCPLAY_TLS_PATH}"
fi

exec "$@"
