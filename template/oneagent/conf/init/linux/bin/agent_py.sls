{% set list = pillar.get('bin') %}
{% if list %}
{% for agent in list %}
{{ agent.name }}:
  file.managed:
  - name: {{ agent.name }}
  - source: {{ agent.source }}
  - source_hash: {{ agent.hash }}
  - user: root
  - group: root
  - mode: 755
  - makedirs: True
{% endfor %}
{% endif %}