package k8s.authz

import data.kubernetes
import data.users

# Users in the app-log-readers group should only be allowed reading logs from some pods in a given namespace.
deny[reason] {
    input.spec.resourceAttributes.namespace == "default"
    input.spec.resourceAttributes.verb == "get"
    input.spec.resourceAttributes.resource == "pods/log"

    # Work with groups rather than users directly
    input.spec.groups[_] == "app-log-readers"

    # App log readers can only read logs from pods prefixed with "app"
    not startswith(input.spec.resourceAttributes.name, "app")

    reason := "App log readers may only read logs from pods with app prefix"
}

# Developers should be allowed read access to all namespaces, except for kube-system.
deny[reason] {
    input.spec.resourceAttributes.verb == "get"
    input.spec.groups[_] == "developers"
    input.spec.resourceAttributes.namespace == "kube-system"

    reason := "Developers not allowed read access to namespace kube-system"
}

# # Some users should be allowed admin access, but only when being on call.
# deny[reason] {
#     input.spec.groups[_] == "on-call-admins"
#     time.now_ns() < time.parse_rfc3339_ns(data.users[input.user].on_call_start)

#     reason := "Admin is not yet on call"
# }

# # Some users should be allowed admin access, but only when being on call.
# deny[reason] {
#     input.spec.groups[_] == "on-call-admins"
#     time.now_ns() > time.parse_rfc3339_ns(data.users[input.user].on_call_end)

#     reason := "Admin is no longer on call"
# }

# # Developers should be allowed access to any resources with a team name label matching the team the user is in.
# deny[reason] {
#     input.spec.groups[_] == "developers"

#     namespace := input.spec.resourceAttributes.namespace
#     resource := input.spec.resourceAttributes.resource
#     name := input.spec.resourceAttributes.name
#     team := [t | t := groups[_]; startswith(t, "team-")][0]

#     not kubernetes[namespace][resource][name].metadata.labels.owner == team
# }

decision = {
    "apiVersion": "v1",
    "kind": "SubjectAccessReview",
    "status": {
        "allowed": count(deny) == 0,
        "reason": concat(" | ", deny),
    },
}