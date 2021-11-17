#cloud-config
# vim: syntax=yaml
write_files:
- path: /etc/environment
  content: |
%{ for env_key, env_value in ENV_VARS ~}
    ${env_key}="${env_value}"
%{ endfor ~}
  append: true
