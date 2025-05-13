server 'your_server_ip', port: 22, user: 'deploy', roles: %w{app db web}, primary: true

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey)
}

set :puma_service_unit_name, "puma_#{fetch(:application)}_production"