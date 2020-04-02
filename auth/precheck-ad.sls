# Note:
#  1. currently only has simple network ping to see if test.com ad server is reachable.
#
{% if salt['grains.get']('os_family') == 'RedHat' %}
{% elif grains['os_family'] == 'Debian' %}
{% else %}

{% endif %}

{% if salt['grains.get']('os_family') == 'RedHat' %}

salt:
  module:
    - stateful: True
    - failhard: True
    - run
    - name: network.ping
    - host: test.com

{% endif %}


{% if salt['grains.get']('os_family') == 'Debian' %}


{% endif %}

