server "62.173.148.168", 
  user: "deploy", 
  roles: %w[app db web], 
  ssh_options: {
    keys: %w(~/.ssh/id_rsa),
    forward_agent: true
  }