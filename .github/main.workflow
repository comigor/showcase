workflow "Deploy if tagged" {
  on = "push"
  resolves = ["Deploy"]
}

action "TagFilter" {
  uses = "actions/bin/filter@master"
  args = "tag v*"
}

action "Deploy" {
  uses = "Igor1201/actions/pub-publish@master"
  secrets = ["PUB_ACCESS_TOKEN", "PUB_REFRESH_TOKEN", "PUB_EXPIRATION"]
  needs = ["TagFilter"]
}
