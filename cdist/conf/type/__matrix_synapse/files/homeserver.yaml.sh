#!/bin/sh

# NOTE: this template has been generated using the
# matrix-synapse-1.5.1-1.fc31.noarch Fedora package for use with CDIST.

generate_database () {
  if [ "$DATABASE_ENGINE" = "sqlite3" ]; then
    cat << EOF
database:
  # The database engine name
  name: "$DATABASE_ENGINE"
  # Arguments to pass to the engine
  args:
    # Path to the database
    database: "$DATABASE_NAME"
EOF
  else
cat << EOF
database:
  # The database engine name
  name: "$DATABASE_ENGINE"
  # Arguments to pass to the engine
  args:
    database: "$DATABASE_NAME"
    host: "$DATABASE_HOST"
    user: "$DATABASE_USER"
    password: "$DATABASE_PASSWORD"
EOF
  fi
}

generate_password_providers () {
  if [ "$ENABLE_LDAP_AUTH" = "true" ]; then
    cat <<EOF
password_providers:
    - module: "ldap_auth_provider.LdapAuthProvider"
      config:
        enabled: $ENABLE_LDAP_AUTH
        uri: "$LDAP_URI"
        start_tls: true
        base: "$LDAP_BASE_DN"
        attributes:
           uid: "$LDAP_UID_ATTRIBUTE"
           mail: "$LDAP_MAIL_ATTRIBUTE"
           name: "$LDAP_NAME_ATTRIBUTE"
        filter: "$LDAP_FILTER"
EOF
    if [ $LDAP_SEARCH_MODE ]; then
        cat <<EOF
        mode: "search"
        bind_dn: "$LDAP_BIND_DN"
        bind_password: "$LDAP_BIND_PASSWORD"
EOF
    fi
  else # LDAP auth is disabled.
    echo "password_providers: []"
  fi
}

generate_resources () {
    if [ "$EXPOSE_METRICS" = "true" ]; then
      echo "[client, federation, metrics]"
    else
      echo "[client, federation]"
    fi
}

cat << EOF
## Server ##

# The domain name of the server, with optional explicit port.
# This is used by remote servers to connect to this server,
# e.g. matrix.org, localhost:8080, etc.
# This is also the last part of your UserID.
#
server_name: "$SERVER_NAME"

# When running as a daemon, the file to store the pid in
#
pid_file: "$PIDFILE"

# The path to the web client which will be served at /_matrix/client/
# if 'webclient' is configured under the 'listeners' configuration.
#
#web_client_location: "/path/to/web/root"

# The public-facing base URL that clients use to access this HS
# (not including _matrix/...). This is the same URL a user would
# enter into the 'custom HS URL' field on their client. If you
# use synapse with a reverse proxy, this should be the URL to reach
# synapse via the proxy.
#
public_baseurl: "$BASE_URL"

# Set the soft limit on the number of file descriptors synapse can use
# Zero is used to indicate synapse should set the soft limit to the
# hard limit.
#
#soft_file_limit: 0

# Set to false to disable presence tracking on this homeserver.
#
#use_presence: false

# Whether to require authentication to retrieve profile data (avatars,
# display names) of other users through the client API. Defaults to
# 'false'. Note that profile data is also available via the federation
# API, so this setting is of limited value if federation is enabled on
# the server.
#
#require_auth_for_profile_requests: true

# If set to 'false', requires authentication to access the server's public rooms
# directory through the client API. Defaults to 'true'.
#
#allow_public_rooms_without_auth: false

# If set to 'false', forbids any other homeserver to fetch the server's public
# rooms directory via federation. Defaults to 'true'.
#
#allow_public_rooms_over_federation: false

# The default room version for newly created rooms.
#
# Known room versions are listed here:
# https://matrix.org/docs/spec/#complete-list-of-room-versions
#
# For example, for room version 1, default_room_version should be set
# to "1".
#
#default_room_version: "4"

# The GC threshold parameters to pass to \`gc.set_threshold\`, if defined
#
#gc_thresholds: [700, 10, 10]

# Set the limit on the returned events in the timeline in the get
# and sync operations. The default value is -1, means no upper limit.
#
#filter_timeline_limit: 5000

# Whether room invites to users on this server should be blocked
# (except those sent by local server admins). The default is False.
#
#block_non_admin_invites: true

# Room searching
#
# If disabled, new messages will not be indexed for searching and users
# will receive errors when searching for messages. Defaults to enabled.
#
#enable_search: false

# Restrict federation to the following whitelist of domains.
# N.B. we recommend also firewalling your federation listener to limit
# inbound federation traffic as early as possible, rather than relying
# purely on this application-layer restriction.  If not specified, the
# default is to whitelist everything.
#
#federation_domain_whitelist:
#  - lon.example.com
#  - nyc.example.com
#  - syd.example.com

# Prevent federation requests from being sent to the following
# blacklist IP address CIDR ranges. If this option is not specified, or
# specified with an empty list, no ip range blacklist will be enforced.
#
# As of Synapse v1.4.0 this option also affects any outbound requests to identity
# servers provided by user input.
#
# (0.0.0.0 and :: are always blacklisted, whether or not they are explicitly
# listed here, since they correspond to unroutable addresses.)
#
federation_ip_range_blacklist:
  - '127.0.0.0/8'
  - '10.0.0.0/8'
  - '172.16.0.0/12'
  - '192.168.0.0/16'
  - '100.64.0.0/10'
  - '169.254.0.0/16'
  - '::1/128'
  - 'fe80::/64'
  - 'fc00::/7'

# List of ports that Synapse should listen on, their purpose and their
# configuration.
#
# Options for each listener include:
#
#   port: the TCP port to bind to
#
#   bind_addresses: a list of local addresses to listen on. The default is
#       'all local interfaces'.
#
#   type: the type of listener. Normally 'http', but other valid options are:
#       'manhole' (see docs/manhole.md),
#       'metrics' (see docs/metrics-howto.md),
#       'replication' (see docs/workers.md).
#
#   tls: set to true to enable TLS for this listener. Will use the TLS
#       key/cert specified in tls_private_key_path / tls_certificate_path.
#
#   x_forwarded: Only valid for an 'http' listener. Set to true to use the
#       X-Forwarded-For header as the client IP. Useful when Synapse is
#       behind a reverse-proxy.
#
#   resources: Only valid for an 'http' listener. A list of resources to host
#       on this port. Options for each resource are:
#
#       names: a list of names of HTTP resources. See below for a list of
#           valid resource names.
#
#       compress: set to true to enable HTTP comression for this resource.
#
#   additional_resources: Only valid for an 'http' listener. A map of
#        additional endpoints which should be loaded via dynamic modules.
#
# Valid resource names are:
#
#   client: the client-server API (/_matrix/client), and the synapse admin
#       API (/_synapse/admin). Also implies 'media' and 'static'.
#
#   consent: user consent forms (/_matrix/consent). See
#       docs/consent_tracking.md.
#
#   federation: the server-server API (/_matrix/federation). Also implies
#       'media', 'keys', 'openid'
#
#   keys: the key discovery API (/_matrix/keys).
#
#   media: the media API (/_matrix/media).
#
#   metrics: the metrics interface. See docs/metrics-howto.md.
#
#   openid: OpenID authentication.
#
#   replication: the HTTP replication API (/_synapse/replication). See
#       docs/workers.md.
#
#   static: static resources under synapse/static (/_matrix/static). (Mostly
#       useful for 'fallback authentication'.)
#
#   webclient: A web client. Requires web_client_location to be set.
#
listeners:
  # TLS-enabled listener: for when matrix traffic is sent directly to synapse.
  #
  # Disabled by default. To enable it, uncomment the following. (Note that you
  # will also need to give Synapse a TLS key and certificate: see the TLS section
  # below.)
  #
  #- port: 8448
  #  type: http
  #  tls: true
  #  resources:
  #    - names: [client, federation]

  # Unsecure HTTP listener: for when matrix traffic passes through a reverse proxy
  # that unwraps TLS.
  #
  # If you plan to use a reverse proxy, please see
  # https://github.com/matrix-org/synapse/blob/master/docs/reverse_proxy.md.
  #
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    bind_addresses: ['::1', '127.0.0.1']

    resources:
      - names: $(generate_resources)
        compress: false

    # example additional_resources:
    #
    #additional_resources:
    #  "/_matrix/my/custom/endpoint":
    #    module: my_module.CustomRequestHandler
    #    config: {}

  # Turn on the twisted ssh manhole service on localhost on the given
  # port.
  #
  #- port: 9000
  #  bind_addresses: ['::1', '127.0.0.1']
  #  type: manhole


## Homeserver blocking ##

# How to reach the server admin, used in ResourceLimitError
#
#admin_contact: 'mailto:admin@server.com'

# Global blocking
#
#hs_disabled: false
#hs_disabled_message: 'Human readable reason for why the HS is blocked'

# Monthly Active User Blocking
#
# Used in cases where the admin or server owner wants to limit to the
# number of monthly active users.
#
# 'limit_usage_by_mau' disables/enables monthly active user blocking. When
# anabled and a limit is reached the server returns a 'ResourceLimitError'
# with error type Codes.RESOURCE_LIMIT_EXCEEDED
#
# 'max_mau_value' is the hard limit of monthly active users above which
# the server will start blocking user actions.
#
# 'mau_trial_days' is a means to add a grace period for active users. It
# means that users must be active for this number of days before they
# can be considered active and guards against the case where lots of users
# sign up in a short space of time never to return after their initial
# session.
#
# 'mau_limit_alerting' is a means of limiting client side alerting
# should the mau limit be reached. This is useful for small instances
# where the admin has 5 mau seats (say) for 5 specific people and no
# interest increasing the mau limit further. Defaults to True, which
# means that alerting is enabled
#
#limit_usage_by_mau: false
#max_mau_value: 50
#mau_trial_days: 2
#mau_limit_alerting: false

# If enabled, the metrics for the number of monthly active users will
# be populated, however no one will be limited. If limit_usage_by_mau
# is true, this is implied to be true.
#
#mau_stats_only: false

# Sometimes the server admin will want to ensure certain accounts are
# never blocked by mau checking. These accounts are specified here.
#
#mau_limit_reserved_threepids:
#  - medium: 'email'
#    address: 'reserved_user@example.com'

# Used by phonehome stats to group together related servers.
#server_context: context

# Resource-constrained Homeserver Settings
#
# If limit_remote_rooms.enabled is True, the room complexity will be
# checked before a user joins a new remote room. If it is above
# limit_remote_rooms.complexity, it will disallow joining or
# instantly leave.
#
# limit_remote_rooms.complexity_error can be set to customise the text
# displayed to the user when a room above the complexity threshold has
# its join cancelled.
#
# Uncomment the below lines to enable:
#limit_remote_rooms:
#  enabled: true
#  complexity: 1.0
#  complexity_error: "This room is too complex."

# Whether to require a user to be in the room to add an alias to it.
# Defaults to 'true'.
#
#require_membership_for_aliases: false

# Whether to allow per-room membership profiles through the send of membership
# events with profile information that differ from the target's global profile.
# Defaults to 'true'.
#
#allow_per_room_profiles: false

# How long to keep redacted events in unredacted form in the database. After
# this period redacted events get replaced with their redacted form in the DB.
#
# Defaults to \`7d\`. Set to \`null\` to disable.
#
#redaction_retention_period: 28d

# How long to track users' last seen time and IPs in the database.
#
# Defaults to \`28d\`. Set to \`null\` to disable clearing out of old rows.
#
#user_ips_max_age: 14d


## TLS ##

# PEM-encoded X509 certificate for TLS.
# This certificate, as of Synapse 1.0, will need to be a valid and verifiable
# certificate, signed by a recognised Certificate Authority.
#
# See 'ACME support' below to enable auto-provisioning this certificate via
# Let's Encrypt.
#
# If supplying your own, be sure to use a \`.pem\` file that includes the
# full certificate chain including any intermediate certificates (for
# instance, if using certbot, use \`fullchain.pem\` as your certificate,
# not \`cert.pem\`).
#
#tls_certificate_path: "CONFDIR/SERVERNAME.tls.crt"

# PEM-encoded private key for TLS
#
#tls_private_key_path: "CONFDIR/SERVERNAME.tls.key"

# Whether to verify TLS server certificates for outbound federation requests.
#
# Defaults to \`true\`. To disable certificate verification, uncomment the
# following line.
#
#federation_verify_certificates: false

# The minimum TLS version that will be used for outbound federation requests.
#
# Defaults to \`1\`. Configurable to \`1\`, \`1.1\`, \`1.2\`, or \`1.3\`. Note
# that setting this value higher than \`1.2\` will prevent federation to most
# of the public Matrix network: only configure it to \`1.3\` if you have an
# entirely private federation setup and you can ensure TLS 1.3 support.
#
#federation_client_minimum_tls_version: 1.2

# Skip federation certificate verification on the following whitelist
# of domains.
#
# This setting should only be used in very specific cases, such as
# federation over Tor hidden services and similar. For private networks
# of homeservers, you likely want to use a private CA instead.
#
# Only effective if federation_verify_certicates is \`true\`.
#
#federation_certificate_verification_whitelist:
#  - lon.example.com
#  - *.domain.com
#  - *.onion

# List of custom certificate authorities for federation traffic.
#
# This setting should only normally be used within a private network of
# homeservers.
#
# Note that this list will replace those that are provided by your
# operating environment. Certificates must be in PEM format.
#
#federation_custom_ca_list:
#  - myCA1.pem
#  - myCA2.pem
#  - myCA3.pem

# ACME support: This will configure Synapse to request a valid TLS certificate
# for your configured \`server_name\` via Let's Encrypt.
#
# Note that provisioning a certificate in this way requires port 80 to be
# routed to Synapse so that it can complete the http-01 ACME challenge.
# By default, if you enable ACME support, Synapse will attempt to listen on
# port 80 for incoming http-01 challenges - however, this will likely fail
# with 'Permission denied' or a similar error.
#
# There are a couple of potential solutions to this:
#
#  * If you already have an Apache, Nginx, or similar listening on port 80,
#    you can configure Synapse to use an alternate port, and have your web
#    server forward the requests. For example, assuming you set 'port: 8009'
#    below, on Apache, you would write:
#
#    ProxyPass /.well-known/acme-challenge http://localhost:8009/.well-known/acme-challenge
#
#  * Alternatively, you can use something like \`authbind\` to give Synapse
#    permission to listen on port 80.
#
acme:
    # ACME support is disabled by default. Set this to \`true\` and uncomment
    # tls_certificate_path and tls_private_key_path above to enable it.
    #
    enabled: false

    # Endpoint to use to request certificates. If you only want to test,
    # use Let's Encrypt's staging url:
    #     https://acme-staging.api.letsencrypt.org/directory
    #
    #url: https://acme-v01.api.letsencrypt.org/directory

    # Port number to listen on for the HTTP-01 challenge. Change this if
    # you are forwarding connections through Apache/Nginx/etc.
    #
    port: 80

    # Local addresses to listen on for incoming connections.
    # Again, you may want to change this if you are forwarding connections
    # through Apache/Nginx/etc.
    #
    bind_addresses: ['::', '0.0.0.0']

    # How many days remaining on a certificate before it is renewed.
    #
    reprovision_threshold: 30

    # The domain that the certificate should be for. Normally this
    # should be the same as your Matrix domain (i.e., 'server_name'), but,
    # by putting a file at 'https://<server_name>/.well-known/matrix/server',
    # you can delegate incoming traffic to another server. If you do that,
    # you should give the target of the delegation here.
    #
    # For example: if your 'server_name' is 'example.com', but
    # 'https://example.com/.well-known/matrix/server' delegates to
    # 'matrix.example.com', you should put 'matrix.example.com' here.
    #
    # If not set, defaults to your 'server_name'.
    #
    domain: matrix.example.com

    # file to use for the account key. This will be generated if it doesn't
    # exist.
    #
    # If unspecified, we will use CONFDIR/client.key.
    #
    account_key_file: "$DATA_DIR/acme_account.key"

# List of allowed TLS fingerprints for this server to publish along
# with the signing keys for this server. Other matrix servers that
# make HTTPS requests to this server will check that the TLS
# certificates returned by this server match one of the fingerprints.
#
# Synapse automatically adds the fingerprint of its own certificate
# to the list. So if federation traffic is handled directly by synapse
# then no modification to the list is required.
#
# If synapse is run behind a load balancer that handles the TLS then it
# will be necessary to add the fingerprints of the certificates used by
# the loadbalancers to this list if they are different to the one
# synapse is using.
#
# Homeservers are permitted to cache the list of TLS fingerprints
# returned in the key responses up to the "valid_until_ts" returned in
# key. It may be necessary to publish the fingerprints of a new
# certificate and wait until the "valid_until_ts" of the previous key
# responses have passed before deploying it.
#
# You can calculate a fingerprint from a given TLS listener via:
# openssl s_client -connect $host:$port < /dev/null 2> /dev/null |
#   openssl x509 -outform DER | openssl sha256 -binary | base64 | tr -d '='
# or by checking matrix.org/federationtester/api/report?server_name=$host
#
#tls_fingerprints: [{"sha256": "<base64_encoded_sha256_fingerprint>"}]



## Database ##

$(generate_database)

# Number of events to cache in memory.
#
#event_cache_size: 10K


## Logging ##

# A yaml python logging config file as described by
# https://docs.python.org/3.7/library/logging.config.html#configuration-dictionary-schema
#
log_config: "$LOG_CONFIG_PATH"


## Ratelimiting ##

# Ratelimiting settings for client actions (registration, login, messaging).
#
# Each ratelimiting configuration is made of two parameters:
#   - per_second: number of requests a client can send per second.
#   - burst_count: number of requests a client can send before being throttled.
#
# Synapse currently uses the following configurations:
#   - one for messages that ratelimits sending based on the account the client
#     is using
#   - one for registration that ratelimits registration requests based on the
#     client's IP address.
#   - one for login that ratelimits login requests based on the client's IP
#     address.
#   - one for login that ratelimits login requests based on the account the
#     client is attempting to log into.
#   - one for login that ratelimits login requests based on the account the
#     client is attempting to log into, based on the amount of failed login
#     attempts for this account.
#   - one for ratelimiting redactions by room admins. If this is not explicitly
#     set then it uses the same ratelimiting as per rc_message. This is useful
#     to allow room admins to deal with abuse quickly.
#
# The defaults are as shown below.
#
#rc_message:
#  per_second: 0.2
#  burst_count: 10
#
#rc_registration:
#  per_second: 0.17
#  burst_count: 3
#
#rc_login:
#  address:
#    per_second: 0.17
#    burst_count: 3
#  account:
#    per_second: 0.17
#    burst_count: 3
#  failed_attempts:
#    per_second: 0.17
#    burst_count: 3
#
#rc_admin_redaction:
#  per_second: 1
#  burst_count: 50


# Ratelimiting settings for incoming federation
#
# The rc_federation configuration is made up of the following settings:
#   - window_size: window size in milliseconds
#   - sleep_limit: number of federation requests from a single server in
#     a window before the server will delay processing the request.
#   - sleep_delay: duration in milliseconds to delay processing events
#     from remote servers by if they go over the sleep limit.
#   - reject_limit: maximum number of concurrent federation requests
#     allowed from a single server
#   - concurrent: number of federation requests to concurrently process
#     from a single server
#
# The defaults are as shown below.
#
#rc_federation:
#  window_size: 1000
#  sleep_limit: 10
#  sleep_delay: 500
#  reject_limit: 50
#  concurrent: 3

# Target outgoing federation transaction frequency for sending read-receipts,
# per-room.
#
# If we end up trying to send out more read-receipts, they will get buffered up
# into fewer transactions.
#
#federation_rr_transactions_per_room_per_second: 50



## Media Store ##

# Enable the media store service in the Synapse master. Uncomment the
# following if you are using a separate media store worker.
#
#enable_media_repo: false

# Directory where uploaded images and attachments are stored.
#
media_store_path: "$DATA_DIR/media_store"

# Media storage providers allow media to be stored in different
# locations.
#
#media_storage_providers:
#  - module: file_system
#    # Whether to write new local files.
#    store_local: false
#    # Whether to write new remote media
#    store_remote: false
#    # Whether to block upload requests waiting for write to this
#    # provider to complete
#    store_synchronous: false
#    config:
#       directory: /mnt/some/other/directory

# Directory where in-progress uploads are stored.
#
uploads_path: "$DATA_DIR/uploads"

# The largest allowed upload size in bytes
#
max_upload_size: "$MAX_UPLOAD_SIZE"

# Maximum number of pixels that will be thumbnailed
#
#max_image_pixels: 32M

# Whether to generate new thumbnails on the fly to precisely match
# the resolution requested by the client. If true then whenever
# a new resolution is requested by the client the server will
# generate a new thumbnail. If false the server will pick a thumbnail
# from a precalculated list.
#
#dynamic_thumbnails: false

# List of thumbnails to precalculate when an image is uploaded.
#
#thumbnail_sizes:
#  - width: 32
#    height: 32
#    method: crop
#  - width: 96
#    height: 96
#    method: crop
#  - width: 320
#    height: 240
#    method: scale
#  - width: 640
#    height: 480
#    method: scale
#  - width: 800
#    height: 600
#    method: scale

# Is the preview URL API enabled?
#
# 'false' by default: uncomment the following to enable it (and specify a
# url_preview_ip_range_blacklist blacklist).
#
#url_preview_enabled: true

# List of IP address CIDR ranges that the URL preview spider is denied
# from accessing.  There are no defaults: you must explicitly
# specify a list for URL previewing to work.  You should specify any
# internal services in your network that you do not want synapse to try
# to connect to, otherwise anyone in any Matrix room could cause your
# synapse to issue arbitrary GET requests to your internal services,
# causing serious security issues.
#
# (0.0.0.0 and :: are always blacklisted, whether or not they are explicitly
# listed here, since they correspond to unroutable addresses.)
#
# This must be specified if url_preview_enabled is set. It is recommended that
# you uncomment the following list as a starting point.
#
#url_preview_ip_range_blacklist:
#  - '127.0.0.0/8'
#  - '10.0.0.0/8'
#  - '172.16.0.0/12'
#  - '192.168.0.0/16'
#  - '100.64.0.0/10'
#  - '169.254.0.0/16'
#  - '::1/128'
#  - 'fe80::/64'
#  - 'fc00::/7'

# List of IP address CIDR ranges that the URL preview spider is allowed
# to access even if they are specified in url_preview_ip_range_blacklist.
# This is useful for specifying exceptions to wide-ranging blacklisted
# target IP ranges - e.g. for enabling URL previews for a specific private
# website only visible in your network.
#
#url_preview_ip_range_whitelist:
#   - '192.168.1.1'

# Optional list of URL matches that the URL preview spider is
# denied from accessing.  You should use url_preview_ip_range_blacklist
# in preference to this, otherwise someone could define a public DNS
# entry that points to a private IP address and circumvent the blacklist.
# This is more useful if you know there is an entire shape of URL that
# you know that will never want synapse to try to spider.
#
# Each list entry is a dictionary of url component attributes as returned
# by urlparse.urlsplit as applied to the absolute form of the URL.  See
# https://docs.python.org/2/library/urlparse.html#urlparse.urlsplit
# The values of the dictionary are treated as an filename match pattern
# applied to that component of URLs, unless they start with a ^ in which
# case they are treated as a regular expression match.  If all the
# specified component matches for a given list item succeed, the URL is
# blacklisted.
#
#url_preview_url_blacklist:
#  # blacklist any URL with a username in its URI
#  - username: '*'
#
#  # blacklist all *.google.com URLs
#  - netloc: 'google.com'
#  - netloc: '*.google.com'
#
#  # blacklist all plain HTTP URLs
#  - scheme: 'http'
#
#  # blacklist http(s)://www.acme.com/foo
#  - netloc: 'www.acme.com'
#    path: '/foo'
#
#  # blacklist any URL with a literal IPv4 address
#  - netloc: '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'

# The largest allowed URL preview spidering size in bytes
#
#max_spider_size: 10M


## Captcha ##
# See docs/CAPTCHA_SETUP for full details of configuring this.

# This Home Server's ReCAPTCHA public key.
#
#recaptcha_public_key: "YOUR_PUBLIC_KEY"

# This Home Server's ReCAPTCHA private key.
#
#recaptcha_private_key: "YOUR_PRIVATE_KEY"

# Enables ReCaptcha checks when registering, preventing signup
# unless a captcha is answered. Requires a valid ReCaptcha
# public/private key.
#
#enable_registration_captcha: false

# A secret key used to bypass the captcha test entirely.
#
#captcha_bypass_secret: "YOUR_SECRET_HERE"

# The API endpoint to use for verifying m.login.recaptcha responses.
#
#recaptcha_siteverify_api: "https://www.recaptcha.net/recaptcha/api/siteverify"


## TURN ##

# The public URIs of the TURN server to give to clients
#
turn_uris: $TURN_URIS

# The shared secret used to compute passwords for the TURN server
#
turn_shared_secret: "$TURN_SHARED_SECRET"

# The Username and password if the TURN server needs them and
# does not use a token
#
#turn_username: "TURNSERVER_USERNAME"
#turn_password: "TURNSERVER_PASSWORD"

# How long generated TURN credentials last
#
turn_user_lifetime: "$TURN_USER_LIFETIME"

# Whether guests should be allowed to use the TURN server.
# This defaults to True, otherwise VoIP will be unreliable for guests.
# However, it does introduce a slight security risk as it allows users to
# connect to arbitrary endpoints without having first signed up for a
# valid account (e.g. by passing a CAPTCHA).
#
#turn_allow_guests: true

## Registration ##
#
# Registration can be rate-limited using the parameters in the "Ratelimiting"
# section of this file.

# Enable registration for new users.
#
enable_registration: $ALLOW_REGISTRATION

# Optional account validity configuration. This allows for accounts to be denied
# any request after a given period.
#
# \`\`enabled\`\` defines whether the account validity feature is enabled. Defaults
# to False.
#
# \`\`period\`\` allows setting the period after which an account is valid
# after its registration. When renewing the account, its validity period
# will be extended by this amount of time. This parameter is required when using
# the account validity feature.
#
# \`\`renew_at\`\` is the amount of time before an account's expiry date at which
# Synapse will send an email to the account's email address with a renewal link.
# This needs the \`\`email\`\` and \`\`public_baseurl\`\` configuration sections to be
# filled.
#
# \`\`renew_email_subject\`\` is the subject of the email sent out with the renewal
# link. \`\`%(app)s\`\` can be used as a placeholder for the \`\`app_name\`\` parameter
# from the \`\`email\`\` section.
#
# Once this feature is enabled, Synapse will look for registered users without an
# expiration date at startup and will add one to every account it found using the
# current settings at that time.
# This means that, if a validity period is set, and Synapse is restarted (it will
# then derive an expiration date from the current validity period), and some time
# after that the validity period changes and Synapse is restarted, the users'
# expiration dates won't be updated unless their account is manually renewed. This
# date will be randomly selected within a range [now + period - d ; now + period],
# where d is equal to 10% of the validity period.
#
#account_validity:
#  enabled: true
#  period: 6w
#  renew_at: 1w
#  renew_email_subject: "Renew your %(app)s account"
#  # Directory in which Synapse will try to find the HTML files to serve to the
#  # user when trying to renew an account. Optional, defaults to
#  # synapse/res/templates.
#  template_dir: "res/templates"
#  # HTML to be displayed to the user after they successfully renewed their
#  # account. Optional.
#  account_renewed_html_path: "account_renewed.html"
#  # HTML to be displayed when the user tries to renew an account with an invalid
#  # renewal token. Optional.
#  invalid_token_html_path: "invalid_token.html"

# Time that a user's session remains valid for, after they log in.
#
# Note that this is not currently compatible with guest logins.
#
# Note also that this is calculated at login time: changes are not applied
# retrospectively to users who have already logged in.
#
# By default, this is infinite.
#
#session_lifetime: 24h

# The user must provide all of the below types of 3PID when registering.
#
#registrations_require_3pid:
#  - email
#  - msisdn

# Explicitly disable asking for MSISDNs from the registration
# flow (overrides registrations_require_3pid if MSISDNs are set as required)
#
#disable_msisdn_registration: true

# Mandate that users are only allowed to associate certain formats of
# 3PIDs with accounts on this server.
#
#allowed_local_3pids:
#  - medium: email
#    pattern: '.*@matrix\.org'
#  - medium: email
#    pattern: '.*@vector\.im'
#  - medium: msisdn
#    pattern: '\+44'

# Enable 3PIDs lookup requests to identity servers from this server.
#
#enable_3pid_lookup: true

# If set, allows registration of standard or admin accounts by anyone who
# has the shared secret, even if registration is otherwise disabled.
#
# registration_shared_secret: <PRIVATE STRING>

# Set the number of bcrypt rounds used to generate password hash.
# Larger numbers increase the work factor needed to generate the hash.
# The default number is 12 (which equates to 2^12 rounds).
# N.B. that increasing this will exponentially increase the time required
# to register or login - e.g. 24 => 2^24 rounds which will take >20 mins.
#
#bcrypt_rounds: 12

# Allows users to register as guests without a password/email/etc, and
# participate in rooms hosted on this server which have been made
# accessible to anonymous users.
#
#allow_guest_access: false

# The identity server which we suggest that clients should use when users log
# in on this server.
#
# (By default, no suggestion is made, so it is left up to the client.
# This setting is ignored unless public_baseurl is also set.)
#
#default_identity_server: https://matrix.org

# The list of identity servers trusted to verify third party
# identifiers by this server.
#
# Also defines the ID server which will be called when an account is
# deactivated (one will be picked arbitrarily).
#
# Note: This option is deprecated. Since v0.99.4, Synapse has tracked which identity
# server a 3PID has been bound to. For 3PIDs bound before then, Synapse runs a
# background migration script, informing itself that the identity server all of its
# 3PIDs have been bound to is likely one of the below.
#
# As of Synapse v1.4.0, all other functionality of this option has been deprecated, and
# it is now solely used for the purposes of the background migration script, and can be
# removed once it has run.
#trusted_third_party_id_servers:
#  - matrix.org
#  - vector.im

# Handle threepid (email/phone etc) registration and password resets through a set of
# *trusted* identity servers. Note that this allows the configured identity server to
# reset passwords for accounts!
#
# Be aware that if \`email\` is not set, and SMTP options have not been
# configured in the email config block, registration and user password resets via
# email will be globally disabled.
#
# Additionally, if \`msisdn\` is not set, registration and password resets via msisdn
# will be disabled regardless. This is due to Synapse currently not supporting any
# method of sending SMS messages on its own.
#
# To enable using an identity server for operations regarding a particular third-party
# identifier type, set the value to the URL of that identity server as shown in the
# examples below.
#
# Servers handling the these requests must answer the \`/requestToken\` endpoints defined
# by the Matrix Identity Service API specification:
# https://matrix.org/docs/spec/identity_service/latest
#
# If a delegate is specified, the config option public_baseurl must also be filled out.
#
account_threepid_delegates:
    #email: https://example.com     # Delegate email sending to example.org
    #msisdn: http://localhost:8090  # Delegate SMS sending to this local process

# Users who register on this homeserver will automatically be joined
# to these rooms
#
#auto_join_rooms:
#  - "#example:example.com"

# Where auto_join_rooms are specified, setting this flag ensures that the
# the rooms exist by creating them when the first user on the
# homeserver registers.
# Setting to false means that if the rooms are not manually created,
# users cannot be auto-joined since they do not exist.
#
#autocreate_auto_join_rooms: true


## Metrics ###

# Enable collection and rendering of performance metrics
#
enable_metrics: $EXPOSE_METRICS

# Enable sentry integration
# NOTE: While attempts are made to ensure that the logs don't contain
# any sensitive information, this cannot be guaranteed. By enabling
# this option the sentry server may therefore receive sensitive
# information, and it in turn may then diseminate sensitive information
# through insecure notification channels if so configured.
#
#sentry:
#    dsn: "..."

# Flags to enable Prometheus metrics which are not suitable to be
# enabled by default, either for performance reasons or limited use.
#
metrics_flags:
    # Publish synapse_federation_known_servers, a g auge of the number of
    # servers this homeserver knows about, including itself. May cause
    # performance problems on large homeservers.
    #
    #known_servers: true

# Whether or not to report anonymized homeserver usage statistics.
report_stats: $REPORT_STATS

# The endpoint to report the anonymized homeserver usage statistics to.
# Defaults to https://matrix.org/report-usage-stats/push
#
#report_stats_endpoint: https://example.com/report-usage-stats/push


## API Configuration ##

# A list of event types that will be included in the room_invite_state
#
#room_invite_state_types:
#  - "m.room.join_rules"
#  - "m.room.canonical_alias"
#  - "m.room.avatar"
#  - "m.room.encryption"
#  - "m.room.name"


# A list of application service config files to use
#
#app_service_config_files:
#  - app_service_1.yaml
#  - app_service_2.yaml

# Uncomment to enable tracking of application service IP addresses. Implicitly
# enables MAU tracking for application service users.
#
#track_appservice_user_ips: true


# a secret which is used to sign access tokens. If none is specified,
# the registration_shared_secret is used, if one is given; otherwise,
# a secret key is derived from the signing key.
#
# macaroon_secret_key: <PRIVATE STRING>

# a secret which is used to calculate HMACs for form values, to stop
# falsification of values. Must be specified for the User Consent
# forms to work.
#
# form_secret: <PRIVATE STRING>

## Signing Keys ##

# Path to the signing key to sign messages with
#
signing_key_path: "$SIGNING_KEY_PATH"

# The keys that the server used to sign messages with but won't use
# to sign new messages. E.g. it has lost its private key
#
#old_signing_keys:
#  "ed25519:auto":
#    # Base64 encoded public key
#    key: "The public part of your old signing key."
#    # Millisecond POSIX timestamp when the key expired.
#    expired_ts: 123456789123

# How long key response published by this server is valid for.
# Used to set the valid_until_ts in /key/v2 APIs.
# Determines how quickly servers will query to check which keys
# are still valid.
#
#key_refresh_interval: 1d

# The trusted servers to download signing keys from.
#
# When we need to fetch a signing key, each server is tried in parallel.
#
# Normally, the connection to the key server is validated via TLS certificates.
# Additional security can be provided by configuring a \`verify key\`, which
# will make synapse check that the response is signed by that key.
#
# This setting supercedes an older setting named \`perspectives\`. The old format
# is still supported for backwards-compatibility, but it is deprecated.
#
# 'trusted_key_servers' defaults to matrix.org, but using it will generate a
# warning on start-up. To suppress this warning, set
# 'suppress_key_server_warning' to true.
#
# Options for each entry in the list include:
#
#    server_name: the name of the server. required.
#
#    verify_keys: an optional map from key id to base64-encoded public key.
#       If specified, we will check that the response is signed by at least
#       one of the given keys.
#
#    accept_keys_insecurely: a boolean. Normally, if \`verify_keys\` is unset,
#       and federation_verify_certificates is not \`true\`, synapse will refuse
#       to start, because this would allow anyone who can spoof DNS responses
#       to masquerade as the trusted key server. If you know what you are doing
#       and are sure that your network environment provides a secure connection
#       to the key server, you can set this to \`true\` to override this
#       behaviour.
#
# An example configuration might look like:
#
#trusted_key_servers:
#  - server_name: "my_trusted_server.example.com"
#    verify_keys:
#      "ed25519:auto": "abcdefghijklmnopqrstuvwxyzabcdefghijklmopqr"
#  - server_name: "my_other_trusted_server.example.com"
#
trusted_key_servers:
  - server_name: "matrix.org"

# Uncomment the following to disable the warning that is emitted when the
# trusted_key_servers include 'matrix.org'. See above.
#
#suppress_key_server_warning: true

# The signing keys to use when acting as a trusted key server. If not specified
# defaults to the server signing key.
#
# Can contain multiple keys, one per line.
#
#key_server_signing_keys_path: "key_server_signing_keys.key"


# Enable SAML2 for registration and login. Uses pysaml2.
#
# At least one of \`sp_config\` or \`config_path\` must be set in this section to
# enable SAML login.
#
# (You will probably also want to set the following options to \`false\` to
# disable the regular login/registration flows:
#   * enable_registration
#   * password_config.enabled
#
# Once SAML support is enabled, a metadata file will be exposed at
# https://<server>:<port>/_matrix/saml2/metadata.xml, which you may be able to
# use to configure your SAML IdP with. Alternatively, you can manually configure
# the IdP to use an ACS location of
# https://<server>:<port>/_matrix/saml2/authn_response.
#
saml2_config:
  # \`sp_config\` is the configuration for the pysaml2 Service Provider.
  # See pysaml2 docs for format of config.
  #
  # Default values will be used for the 'entityid' and 'service' settings,
  # so it is not normally necessary to specify them unless you need to
  # override them.
  #
  #sp_config:
  #  # point this to the IdP's metadata. You can use either a local file or
  #  # (preferably) a URL.
  #  metadata:
  #    #local: ["saml2/idp.xml"]
  #    remote:
  #      - url: https://our_idp/metadata.xml
  #
  #    # By default, the user has to go to our login page first. If you'd like
  #    # to allow IdP-initiated login, set 'allow_unsolicited: true' in a
  #    # 'service.sp' section:
  #    #
  #    #service:
  #    #  sp:
  #    #    allow_unsolicited: true
  #
  #    # The examples below are just used to generate our metadata xml, and you
  #    # may well not need them, depending on your setup. Alternatively you
  #    # may need a whole lot more detail - see the pysaml2 docs!
  #
  #    description: ["My awesome SP", "en"]
  #    name: ["Test SP", "en"]
  #
  #    organization:
  #      name: Example com
  #      display_name:
  #        - ["Example co", "en"]
  #      url: "http://example.com"
  #
  #    contact_person:
  #      - given_name: Bob
  #        sur_name: "the Sysadmin"
  #        email_address": ["admin@example.com"]
  #        contact_type": technical

  # Instead of putting the config inline as above, you can specify a
  # separate pysaml2 configuration file:
  #
  #config_path: "CONFDIR/sp_conf.py"

  # the lifetime of a SAML session. This defines how long a user has to
  # complete the authentication process, if allow_unsolicited is unset.
  # The default is 5 minutes.
  #
  #saml_session_lifetime: 5m

  # The SAML attribute (after mapping via the attribute maps) to use to derive
  # the Matrix ID from. 'uid' by default.
  #
  #mxid_source_attribute: displayName

  # The mapping system to use for mapping the saml attribute onto a matrix ID.
  # Options include:
  #  * 'hexencode' (which maps unpermitted characters to '=xx')
  #  * 'dotreplace' (which replaces unpermitted characters with '.').
  # The default is 'hexencode'.
  #
  #mxid_mapping: dotreplace

  # In previous versions of synapse, the mapping from SAML attribute to MXID was
  # always calculated dynamically rather than stored in a table. For backwards-
  # compatibility, we will look for user_ids matching such a pattern before
  # creating a new account.
  #
  # This setting controls the SAML attribute which will be used for this
  # backwards-compatibility lookup. Typically it should be 'uid', but if the
  # attribute maps are changed, it may be necessary to change it.
  #
  # The default is 'uid'.
  #
  #grandfathered_mxid_source_attribute: upn



# Enable CAS for registration and login.
#
#cas_config:
#   enabled: true
#   server_url: "https://cas-server.com"
#   service_url: "https://homeserver.domain.com:8448"
#   #displayname_attribute: name
#   #required_attributes:
#   #    name: value


# The JWT needs to contain a globally unique "sub" (subject) claim.
#
#jwt_config:
#   enabled: true
#   secret: "a secret"
#   algorithm: "HS256"


password_config:
   # Uncomment to disable password login
   #
   #enabled: false

   # Uncomment to disable authentication against the local password
   # database. This is ignored if \`enabled\` is false, and is only useful
   # if you have other password_providers.
   #
   #localdb_enabled: false

   # Uncomment and change to a secret random string for extra security.
   # DO NOT CHANGE THIS AFTER INITIAL SETUP!
   #
   #pepper: "EVEN_MORE_SECRET"



# Enable sending emails for password resets, notification events or
# account expiry notices
#
# If your SMTP server requires authentication, the optional smtp_user &
# smtp_pass variables should be used
#
#email:
#   enable_notifs: false
#   smtp_host: "localhost"
#   smtp_port: 25 # SSL: 465, STARTTLS: 587
#   smtp_user: "exampleusername"
#   smtp_pass: "examplepassword"
#   require_transport_security: false
#   notif_from: "Your Friendly %(app)s Home Server <noreply@example.com>"
#   app_name: Matrix
#
#   # Enable email notifications by default
#   #
#   notif_for_new_users: true
#
#   # Defining a custom URL for Riot is only needed if email notifications
#   # should contain links to a self-hosted installation of Riot; when set
#   # the "app_name" setting is ignored
#   #
#   riot_base_url: "http://localhost/riot"
#
#   # Configure the time that a validation email or text message code
#   # will expire after sending
#   #
#   # This is currently used for password resets
#   #
#   #validation_token_lifetime: 1h
#
#   # Template directory. All template files should be stored within this
#   # directory. If not set, default templates from within the Synapse
#   # package will be used
#   #
#   # For the list of default templates, please see
#   # https://github.com/matrix-org/synapse/tree/master/synapse/res/templates
#   #
#   #template_dir: res/templates
#
#   # Templates for email notifications
#   #
#   notif_template_html: notif_mail.html
#   notif_template_text: notif_mail.txt
#
#   # Templates for account expiry notices
#   #
#   expiry_template_html: notice_expiry.html
#   expiry_template_text: notice_expiry.txt
#
#   # Templates for password reset emails sent by the homeserver
#   #
#   #password_reset_template_html: password_reset.html
#   #password_reset_template_text: password_reset.txt
#
#   # Templates for registration emails sent by the homeserver
#   #
#   #registration_template_html: registration.html
#   #registration_template_text: registration.txt
#
#   # Templates for validation emails sent by the homeserver when adding an email to
#   # your user account
#   #
#   #add_threepid_template_html: add_threepid.html
#   #add_threepid_template_text: add_threepid.txt
#
#   # Templates for password reset success and failure pages that a user
#   # will see after attempting to reset their password
#   #
#   #password_reset_template_success_html: password_reset_success.html
#   #password_reset_template_failure_html: password_reset_failure.html
#
#   # Templates for registration success and failure pages that a user
#   # will see after attempting to register using an email or phone
#   #
#   #registration_template_success_html: registration_success.html
#   #registration_template_failure_html: registration_failure.html
#
#   # Templates for success and failure pages that a user will see after attempting
#   # to add an email or phone to their account
#   #
#   #add_threepid_success_html: add_threepid_success.html
#   #add_threepid_failure_html: add_threepid_failure.html

$(generate_password_providers)

# Clients requesting push notifications can either have the body of
# the message sent in the notification poke along with other details
# like the sender, or just the event ID and room ID (\`event_id_only\`).
# If clients choose the former, this option controls whether the
# notification request includes the content of the event (other details
# like the sender are still included). For \`event_id_only\` push, it
# has no effect.
#
# For modern android devices the notification content will still appear
# because it is loaded by the app. iPhone, however will send a
# notification saying only that a message arrived and who it came from.
#
#push:
#  include_content: true


#spam_checker:
#  module: "my_custom_project.SuperSpamChecker"
#  config:
#    example_option: 'things'


# Uncomment to allow non-server-admin users to create groups on this server
#
#enable_group_creation: true

# If enabled, non server admins can only create groups with local parts
# starting with this prefix
#
#group_creation_prefix: "unofficial/"



# User Directory configuration
#
# 'enabled' defines whether users can search the user directory. If
# false then empty responses are returned to all queries. Defaults to
# true.
#
# 'search_all_users' defines whether to search all users visible to your HS
# when searching the user directory, rather than limiting to users visible
# in public rooms.  Defaults to false.  If you set it True, you'll have to
# rebuild the user_directory search indexes, see
# https://github.com/matrix-org/synapse/blob/master/docs/user_directory.md
#
#user_directory:
#  enabled: true
#  search_all_users: false


# User Consent configuration
#
# for detailed instructions, see
# https://github.com/matrix-org/synapse/blob/master/docs/consent_tracking.md
#
# Parts of this section are required if enabling the 'consent' resource under
# 'listeners', in particular 'template_dir' and 'version'.
#
# 'template_dir' gives the location of the templates for the HTML forms.
# This directory should contain one subdirectory per language (eg, 'en', 'fr'),
# and each language directory should contain the policy document (named as
# '<version>.html') and a success page (success.html).
#
# 'version' specifies the 'current' version of the policy document. It defines
# the version to be served by the consent resource if there is no 'v'
# parameter.
#
# 'server_notice_content', if enabled, will send a user a "Server Notice"
# asking them to consent to the privacy policy. The 'server_notices' section
# must also be configured for this to work. Notices will *not* be sent to
# guest users unless 'send_server_notice_to_guests' is set to true.
#
# 'block_events_error', if set, will block any attempts to send events
# until the user consents to the privacy policy. The value of the setting is
# used as the text of the error.
#
# 'require_at_registration', if enabled, will add a step to the registration
# process, similar to how captcha works. Users will be required to accept the
# policy before their account is created.
#
# 'policy_name' is the display name of the policy users will see when registering
# for an account. Has no effect unless \`require_at_registration\` is enabled.
# Defaults to "Privacy Policy".
#
#user_consent:
#  template_dir: res/templates/privacy
#  version: 1.0
#  server_notice_content:
#    msgtype: m.text
#    body: >-
#      To continue using this homeserver you must review and agree to the
#      terms and conditions at %(consent_uri)s
#  send_server_notice_to_guests: true
#  block_events_error: >-
#    To continue using this homeserver you must review and agree to the
#    terms and conditions at %(consent_uri)s
#  require_at_registration: false
#  policy_name: Privacy Policy
#



# Local statistics collection. Used in populating the room directory.
#
# 'bucket_size' controls how large each statistics timeslice is. It can
# be defined in a human readable short form -- e.g. "1d", "1y".
#
# 'retention' controls how long historical statistics will be kept for.
# It can be defined in a human readable short form -- e.g. "1d", "1y".
#
#
#stats:
#   enabled: true
#   bucket_size: 1d
#   retention: 1y


# Server Notices room configuration
#
# Uncomment this section to enable a room which can be used to send notices
# from the server to users. It is a special room which cannot be left; notices
# come from a special "notices" user id.
#
# If you uncomment this section, you *must* define the system_mxid_localpart
# setting, which defines the id of the user which will be used to send the
# notices.
#
# It's also possible to override the room name, the display name of the
# "notices" user, and the avatar for the user.
#
#server_notices:
#  system_mxid_localpart: notices
#  system_mxid_display_name: "Server Notices"
#  system_mxid_avatar_url: "mxc://server.com/oumMVlgDnLYFaPVkExemNVVZ"
#  room_name: "Server Notices"



# Uncomment to disable searching the public room list. When disabled
# blocks searching local and remote room lists for local and remote
# users by always returning an empty list for all queries.
#
#enable_room_list_search: false

# The \`alias_creation\` option controls who's allowed to create aliases
# on this server.
#
# The format of this option is a list of rules that contain globs that
# match against user_id, room_id and the new alias (fully qualified with
# server name). The action in the first rule that matches is taken,
# which can currently either be "allow" or "deny".
#
# Missing user_id/room_id/alias fields default to "*".
#
# If no rules match the request is denied. An empty list means no one
# can create aliases.
#
# Options for the rules include:
#
#   user_id: Matches against the creator of the alias
#   alias: Matches against the alias being created
#   room_id: Matches against the room ID the alias is being pointed at
#   action: Whether to "allow" or "deny" the request if the rule matches
#
# The default is:
#
#alias_creation_rules:
#  - user_id: "*"
#    alias: "*"
#    room_id: "*"
#    action: allow

# The \`room_list_publication_rules\` option controls who can publish and
# which rooms can be published in the public room list.
#
# The format of this option is the same as that for
# \`alias_creation_rules\`.
#
# If the room has one or more aliases associated with it, only one of
# the aliases needs to match the alias rule. If there are no aliases
# then only rules with \`alias: *\` match.
#
# If no rules match the request is denied. An empty list means no one
# can publish rooms.
#
# Options for the rules include:
#
#   user_id: Matches agaisnt the creator of the alias
#   room_id: Matches against the room ID being published
#   alias: Matches against any current local or canonical aliases
#            associated with the room
#   action: Whether to "allow" or "deny" the request if the rule matches
#
# The default is:
#
#room_list_publication_rules:
#  - user_id: "*"
#    alias: "*"
#    room_id: "*"
#    action: allow


# Server admins can define a Python module that implements extra rules for
# allowing or denying incoming events. In order to work, this module needs to
# override the methods defined in synapse/events/third_party_rules.py.
#
# This feature is designed to be used in closed federations only, where each
# participating server enforces the same rules.
#
#third_party_event_rules:
#  module: "my_custom_project.SuperRulesSet"
#  config:
#    example_option: 'things'


## Opentracing ##

# These settings enable opentracing, which implements distributed tracing.
# This allows you to observe the causal chains of events across servers
# including requests, key lookups etc., across any server running
# synapse or any other other services which supports opentracing
# (specifically those implemented with Jaeger).
#
opentracing:
# tracing is disabled by default. Uncomment the following line to enable it.
#
#enabled: true

    # The list of homeservers we wish to send and receive span contexts and span baggage.
    # See docs/opentracing.rst
    # This is a list of regexes which are matched against the server_name of the
    # homeserver.
    #
    # By defult, it is empty, so no servers are matched.
    #
    #homeserver_whitelist:
    #  - ".*"

    # Jaeger can be configured to sample traces at different rates.
    # All configuration options provided by Jaeger can be set here.
    # Jaeger's configuration mostly related to trace sampling which
    # is documented here:
    # https://www.jaegertracing.io/docs/1.13/sampling/.
    #
    #jaeger_config:
    #  sampler:
    #    type: const
    #    param: 1

    #  Logging whether spans were started and reported
    #
    #  logging:
    #    false
    #
EOF
