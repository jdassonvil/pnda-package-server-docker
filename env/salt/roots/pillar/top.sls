base:
  '*':
    - provision

  'roles:jenkins':
    - match: grain
    - jenkins.containers

  'roles:repository':
    - match: grain
    - repository.containers
