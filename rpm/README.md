# ReadonlyREST RPM packaging example

This directory contains an example RPM packaging flow for installing, upgrading, and removing ReadonlyREST for Elasticsearch and Kibana.

The goal is to make the ReadonlyREST lifecycle safe when it is managed through a custom RPM package. In particular, the RPM lifecycle must always unpatch Elasticsearch and Kibana before removing the ReadonlyREST plugins.

## Contents

```text
rpm/
├── Jenkinsfile
└── scripts/
    ├── install_ror_es.sh
    ├── install_ror_kbn.sh
    ├── uninstall_ror_es.sh
    ├── uninstall_ror_kbn.sh
    ├── post-install.sh
    ├── pre-upgrade.sh
    ├── post-upgrade.sh
    └── pre-uninstall.sh
```

## Jenkinsfile

`Jenkinsfile` shows how to download the ReadonlyREST Elasticsearch and Kibana plugin ZIPs, create stable symlink names, and package everything into an RPM using `fpm`.

The RPM installs its payload under:

```text
/opt/elasticsearch/
```

Expected packaged files:

```text
/opt/elasticsearch/readonlyrest.zip
/opt/elasticsearch/readonlyrest_kbn_universal.zip
/opt/elasticsearch/scripts/install_ror_es.sh
/opt/elasticsearch/scripts/install_ror_kbn.sh
/opt/elasticsearch/scripts/uninstall_ror_es.sh
/opt/elasticsearch/scripts/uninstall_ror_kbn.sh
```

## Lifecycle scripts

### `post-install.sh`

Runs after a fresh RPM install.

Flow:

```text
stop Kibana
stop Elasticsearch
install and patch ReadonlyREST for Elasticsearch
install and patch ReadonlyREST for Kibana
start Elasticsearch
start Kibana
```

### `pre-upgrade.sh`

Runs before an RPM upgrade.

This step is required because ReadonlyREST patches Elasticsearch and Kibana files. During an upgrade, the old ReadonlyREST version must be unpatched and removed before the new version is installed.

Flow:

```text
stop Kibana
stop Elasticsearch
unpatch and remove old ReadonlyREST Kibana plugin
unpatch and remove old ReadonlyREST Elasticsearch plugin
```

It does not restart services. Services are started by `post-upgrade.sh` after the new plugins are installed and patched.

### `post-upgrade.sh`

Runs after the new RPM version is installed.

Flow:

```text
install and patch new ReadonlyREST for Elasticsearch
install and patch new ReadonlyREST for Kibana
start Elasticsearch
start Kibana
```

### `pre-uninstall.sh`

Runs before final RPM removal.

Flow:

```text
stop Kibana
stop Elasticsearch
unpatch and remove ReadonlyREST Kibana plugin
unpatch and remove ReadonlyREST Elasticsearch plugin
start Elasticsearch
start Kibana
```

After this step, Elasticsearch and Kibana should be restored to their unpatched state.

## Helper scripts

### `install_ror_es.sh`

Installs and patches the ReadonlyREST Elasticsearch plugin.

Default paths:

```sh
ES_HOME=/usr/share/elasticsearch
ES_PATH_CONF=/etc/elasticsearch/es-01
RPM_PAYLOAD_DIR=/opt/elasticsearch
ROR_ES_ZIP=/opt/elasticsearch/readonlyrest.zip
```

The script validates that:

```text
Elasticsearch plugin manager exists
Elasticsearch bundled Java exists
Elasticsearch config directory exists
ReadonlyREST plugin ZIP exists
ReadonlyREST is not already installed
```

It then runs:

```text
elasticsearch-plugin install
ror-tools.jar patch
ror-tools.jar verify
```

### `uninstall_ror_es.sh`

Unpatches and removes the ReadonlyREST Elasticsearch plugin.

It performs:

```text
ror-tools.jar unpatch
ror-tools.jar verify
elasticsearch-plugin remove readonlyrest
```

`ror-tools.jar verify` is expected to return non-zero after unpatching, because Elasticsearch is no longer patched. The script handles this case intentionally.

### `install_ror_kbn.sh`

Installs and patches the ReadonlyREST Kibana plugin.

Default paths:

```sh
KBN_HOME=/usr/share/kibana
RPM_PAYLOAD_DIR=/opt/elasticsearch
ROR_KBN_ZIP=/opt/elasticsearch/readonlyrest_kbn_universal.zip
```

The script validates that:

```text
Kibana plugin manager exists
ReadonlyREST Kibana plugin ZIP exists
ReadonlyREST Kibana plugin is not already installed
Kibana bundled Node.js exists
```

It supports these Kibana Node.js paths:

```text
/usr/share/kibana/node/bin/node
/usr/share/kibana/node/glibc-217/bin/node
/usr/share/kibana/node/default/bin/node
```

### `uninstall_ror_kbn.sh`

Unpatches and removes the ReadonlyREST Kibana plugin.

It performs:

```text
ror-tools.js unpatch
ror-tools.js verify
kibana-plugin remove readonlyrestkbn
```

`ror-tools.js verify` may return non-zero after unpatching because Kibana is no longer patched. The script handles this case intentionally.

## Important changes made

### Added explicit pre-upgrade handling

The RPM now uses:

```text
--before-upgrade scripts/pre-upgrade.sh
```

This is required because relying only on `--after-upgrade` is too late. In testing, `post-upgrade.sh` ran while the old ReadonlyREST plugin was still installed, causing the new install step to fail with:

```text
ReadonlyREST Elasticsearch plugin is already installed
```

The fixed upgrade flow is:

```text
pre-upgrade.sh
  unpatch/remove old ROR

post-upgrade.sh
  install/patch new ROR
```

### Added Kibana plugin version to download URL

The Kibana download URL now includes:

```text
pluginVersion=${ROR_VERSION}
```

This ensures that the downloaded Kibana plugin version matches the RPM version being built.

### Stable packaged ZIP names

The RPM payload uses stable filenames:

```text
readonlyrest.zip
readonlyrest_kbn_universal.zip
```

The helper scripts consume these stable names instead of versioned filenames.

### Absolute paths

The scripts use absolute paths instead of relying on the current working directory.

For example:

```sh
/usr/share/elasticsearch/bin/elasticsearch-plugin
/usr/share/elasticsearch/jdk/bin/java
/usr/share/kibana/bin/kibana-plugin
```

For Elasticsearch patching, the scripts explicitly pass:

```sh
--es-path="${ES_HOME}"
```

## Assumptions

This example assumes:

1. Elasticsearch is installed from RPM under:

   ```text
   /usr/share/elasticsearch
   ```

2. Kibana is installed from RPM under:

   ```text
   /usr/share/kibana
   ```

3. Elasticsearch config path is:

   ```text
   /etc/elasticsearch/es-01
   ```

   This can be overridden with:

   ```sh
   ES_PATH_CONF=/path/to/config
   ```

4. The Elasticsearch systemd service name is:

   ```text
   elasticsearch-es-01
   ```

   This can be overridden with:

   ```sh
   SYSTEMD_ES_SERVICE=...
   ```

5. The Kibana systemd service name is:

   ```text
   kibana
   ```

   This can be overridden with:

   ```sh
   SYSTEMD_KBN_SERVICE=...
   ```

6. Both Elasticsearch and Kibana are expected to be present.

7. ReadonlyREST must be unpatched before the plugin is removed.

8. The RPM package owns the ReadonlyREST plugin ZIPs and helper scripts under:

   ```text
   /opt/elasticsearch/
   ```
   