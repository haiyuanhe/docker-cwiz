{% set list = pillar.get('conf') %}
{% if list %}
{% for agent in list %}
{{ agent.name }}:
  file.managed:
  - name: {{ agent.name }}
  - source: {{ agent.source }}
  - source_hash: {{ agent.hash }}
  - user: root
  - group: root
  - mode: 644
  - makedirs: True
{% endfor %}
{% endif %}