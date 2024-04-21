
base:
  '*':
    - base
    # - users  # assuming you have other pillar data like users as previously setup


development:
  '*':
    - base
    - dev



# 'G@environment:dev':
#   - match: compound
#   - docker