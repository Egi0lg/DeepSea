{% set master = salt['master.minion']() %}

{% if (salt.saltutil.runner('select.minions', cluster='ceph', roles='prometheus') != []) %}

populate scrape configs:
  salt.state:
    - tgt: {{ master }}
    - tgt_type: compound
    - sls: ceph.monitoring.prometheus.populate_scrape_configs

populate alertmanager peers:
  salt.state:
    - tgt: {{ master }}
    - tgt_type: compound
    - sls: ceph.monitoring.alertmanager.populate_peers

clear salt file server file list cache:
  salt.runner:
    - name: fileserver.clear_file_list_cache

install prometheus:
  salt.state:
    - tgt: 'I@roles:prometheus and I@cluster:ceph'
    - tgt_type: compound
    - sls: ceph.monitoring.prometheus

push scrape configs:
  salt.state:
    - tgt: 'I@roles:prometheus and I@cluster:ceph'
    - tgt_type: compound
    - sls: ceph.monitoring.prometheus.push_scrape_configs

install alertmanager:
  salt.state:
    - tgt: 'I@roles:prometheus and I@cluster:ceph'
    - tgt_type: compound
    - sls: ceph.monitoring.alertmanager

{% endif %}

{% if (salt.saltutil.runner('select.minions', cluster='ceph', roles='grafana') != []) %}

populate grafana config fragments:
  salt.state:
    - tgt: {{ master }}
    - tgt_type: compound
    - sls: ceph.monitoring.grafana.create_configs

install grafana:
  salt.state:
    - tgt: 'I@roles:grafana and I@cluster:ceph'
    - tgt_type: compound
    - sls: ceph.monitoring.grafana

{% endif %}
