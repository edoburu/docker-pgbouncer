#!/usr/bin/env python3
import hashlib
import re
import typing
import os


PG_CONFIG_DIR='/etc/pgbouncer'
URI_REGEXP = re.compile(
    'postgresql://(?P<username>[^:]+)[:](?P<password>[^@]+)[@](?P<host>[a-zA-Z0-9.\-]+)[:]?(?P<port>[0-9]+)?[/](?P<database>[a-z_]+)'
)


def option(env_name: str, default: typing.Optional[str], name: typing.Optional[str]):
    name = name if name else env_name.lower()
    if env_name in os.environ:
        return f"{name} = {os.environ[env_name]}"
    elif default:
        return f"{name} = {default}"
    else:
        return None


def option_set(*args):
    rendered_opts = [option(*t) for t in args]
    return '\n'.join(ele for ele in rendered_opts if ele)


def md5(s):
    m = hashlib.md5()
    m.update(bytes(s, 'utf-8'))
    return m.hexdigest()


db_dicts = [URI_REGEXP.finditer(s) for s in os.environ['DATABASE_URIS'].split(',')]
db_dicts = [m.groupdict() for sublist in db_dicts for m in sublist]

with open(PG_CONFIG_DIR + '/userlist.txt', 'w') as fh:
    tmp = '\n'.join(set([f"\"{m['username']}\" \"md5{md5(m['password'] + m['username'])}\"" for m in db_dicts]))
    print("\n\n[userlist.txt]\n")
    print(tmp)
    fh.write(tmp)

databases = '\n'.join([
    f"{m['database']} = host={m['host']} port={m.get('port', 5432)} dbname={m.get('database', 'postgres')} user={m.get('username', 'postgres')}"
    for m in db_dicts
])

# Config file is in “ini” format. Section names are between “[” and “]”.
# Lines starting with “;” or “#” are taken as comments and ignored.
# The characters “;” and “#” are not recognized when they appear later in the line.
pg_bouncer = option_set(
    ('AUTH_FILE', PG_CONFIG_DIR + '/userlist.txt', None),
    ('AUTH_TYPE', 'md5', None),
    ('AUTH_HBA_FILE', None, None),
    ('AUTH_QUERY', None, None),
    ('POOL_MODE', None, None),
    ('MAX_CLIENT_CONN', None, None),
    ('DEFAULT_POOL_SIZE', None, None),
    ('MIN_POOL_SIZE', None, None),
    ('RESERVE_POOL_SIZE', None, None),
    ('RESERVE_POOL_TIMEOUT', None, None),
    ('MAX_DB_CONNECTIONS', None, None),
    ('MAX_USER_CONNECTIONS', None, None),
    ('SERVER_ROUND_ROBIN', None, None),
    ('IGNORE_STARTUP_PARAMETERS', 'extra_float_digits', None),
    ('DISABLE_PQEXEC', None, None),
    ('APPLICATION_NAME_ADD_HOST', None, None),
)

log_settings = option_set(
    ('DB_USER', 'postgres', 'admin_users'),
    ('LOG_CONNECTIONS', None, None),
    ('LOG_DISCONNECTIONS', None, None),
    ('LOG_POOLER_ERRORS', None, None),
    ('STATS_PERIOD', None, None),
    ('VERBOSE', None, None),
    ('STATS_USERS', None, None),
)

connection_sanity_checks_timeouts = option_set(
    ('SERVER_RESET_QUERY', None, None),
    ('SERVER_RESET_QUERY_ALWAYS', None, None),
    ('SERVER_CHECK_QUERY', None, None),
    ('SERVER_LIFETIME', None, None),
    ('SERVER_IDLE_TIMEOUT', None, None),
    ('SERVER_CONNECT_TIMEOUT', None, None),
    ('SERVER_LOGIN_RETRY', None, None),
    ('CLIENT_LOGIN_TIMEOUT', None, None),
    ('AUTODB_IDLE_TIMEOUT', None, None),
    ('DNS_MAX_TTL', None, None),
    ('DNS_NXDOMAIN_TTL', None, None),
)

tls_settings = option_set(
    ('CLIENT_TLS_SSLMODE', None, None),
    ('CLIENT_TLS_KEY_FILE', None, None),
    ('CLIENT_TLS_CERT_FILE', None, None),
    ('CLIENT_TLS_CA_FILE', None, None),
    ('CLIENT_TLS_PROTOCOLS', None, None),
    ('CLIENT_TLS_CIPHERS', None, None),
    ('CLIENT_TLS_ECDHCURVE', None, None),
    ('CLIENT_TLS_DHEPARAMS', None, None),
    ('SERVER_TLS_SSLMODE', None, None),
    ('SERVER_TLS_CA_FILE', None, None),
    ('SERVER_TLS_KEY_FILE', None, None),
    ('SERVER_TLS_CERT_FILE', None, None),
    ('SERVER_TLS_PROTOCOLS', None, None),
    ('SERVER_TLS_CIPHERS', None, None),
)

dangerous_timeouts = option_set(
    ('QUERY_TIMEOUT', None, None),
    ('QUERY_WAIT_TIMEOUT', None, None),
    ('CLIENT_IDLE_TIMEOUT', None, None),
    ('IDLE_TRANSACTION_TIMEOUT', None, None),
    ('PKT_BUF', None, None),
    ('MAX_PACKET_SIZE', None, None),
    ('LISTEN_BACKLOG', None, None),
    ('SBUF_LOOPCNT', None, None),
    ('SUSPEND_TIMEOUT', None, None),
    ('TCP_DEFER_ACCEPT', None, None),
    ('TCP_KEEPALIVE', None, None),
    ('TCP_KEEPCNT', None, None),
    ('TCP_KEEPIDLE', None, None),
    ('TCP_KEEPINTVL', None, None),
)

ini_file = f"""
################## Auto generated ##################
[databases]
{databases}

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 5432
unix_socket_dir =
{pg_bouncer}

# Log settings
{log_settings}

# Connection sanity checks, timeouts
{connection_sanity_checks_timeouts}

# TLS settings
{tls_settings}

# Dangerous timeouts
{dangerous_timeouts}
################## end file ##################
"""

with open(f"{PG_CONFIG_DIR}/pgbouncer.ini", 'w') as fh:
    print("\n\n[pgbouncer.ini]\n")
    print(ini_file)
    fh.write(ini_file)
