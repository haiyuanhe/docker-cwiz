module.exports = {
  app_mode: 'development',
  paths: {
    data: '',
    logs: '<:log_root:>/cloudwiz-user',
  },
  'log.file': {
    enable: true,
    filename: 'cloudwiz_user_audit.log',
    max_size_shift: 28,
    max_days: 7
  },
  server: {
    protocol: '<:nginx_protocol:>',
    http_addr: '',
    http_port: 7002,
    domain: '',
    root_url: '/<:nginx_prefix:>_auth',
    app_sub_url: '/<:nginx_prefix:>_auth',
    static_root_path: '',
    cert_file: '<:install_root:>/certs/cloudwiz-user/server.crt',
    cert_key: '<:install_root:>/certs/cloudwiz-user/server.key',
    ca: '<:install_root:>/certs/cloudwiz-user/ca.crt',
  },
  session: {
    cookie_name: 'grafana_sess'
  },
  security: {
    data_source_proxy_whitelist: '',
    cookies_cross_domain: ''
  },
  datasource: {
    urlroot: '<:nginx_protocol:>://<:nginx_ip:>:4124',
    urlintranet: '',
    api_path: '/<:nginx_prefix:>_auth/api',
    cert_file: '<:install_root:>/certs/nginx/client.crt',
    cert_key: '<:install_root:>/certs/nginx/client.key',
    ca: '<:install_root:>/certs/nginx/ca.crt',
  },
  website: {
    logoPath: 'fav32.png',
    logoText: '',
    logoWhite: 'fav32_white.png',
    document_title: '智能运维分析 - 后台管理系统'
  },
  grafana: {
    url: '<:nginx_ext_protocol:>://<:nginx_ext_ip:>:<:nginx_ext_port:><:slash_nginx_prefix:>',
    urlintranet: '<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:><:slash_nginx_prefix:>',
    cert_file: '<:install_root:>/certs/nginx/client.crt',
    cert_key: '<:install_root:>/certs/nginx/client.key',
    ca: '<:install_root:>/certs/nginx/ca.crt',
  },  
  bill: {
    url: ''
  }
}
