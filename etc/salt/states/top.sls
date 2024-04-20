#
# This file is used by SaltStack to map Salt states and formulas to minions.
# It defines the highstate for each minion, determining which states will be applied.
# Each minion's highstate is defined based on its ID or grains (system properties).
#
# To apply all states to a minion, use `sudo salt-call state.apply`.
#
# For more information on SaltStack states and the highstate concept:
#   https://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html
#   https://docs.saltstack.com/en/latest/ref/states/highstate.html
#
# For information on how to use SaltStack as a provisioning tool:
#   https://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html


base:
  '*':
    - base
    - docker

development:
  '*':
    - base
    - docker