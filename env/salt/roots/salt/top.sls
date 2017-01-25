base:

  'roles:jenkins':
    - match: grain
    - dockerhost

  'roles:repository':
    - match: grain
    - dockerhost
