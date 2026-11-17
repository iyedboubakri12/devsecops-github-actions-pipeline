package main

import rego.v1

good := {
	"kind": "Deployment",
	"metadata": {"name": "api"},
	"spec": {"template": {"spec": {
		"securityContext": {"runAsNonRoot": true},
		"containers": [{
			"name": "api",
			"image": "ghcr.io/x/api:1.0.0",
			"resources": {"limits": {"cpu": "250m", "memory": "192Mi"}},
			"securityContext": {"readOnlyRootFilesystem": true, "privileged": false},
		}],
	}}},
}

test_compliant_deployment_passes if {
	count(deny) == 0 with input as good
}

test_missing_limits_denied if {
	bad := json.patch(good, [{"op": "remove", "path": "/spec/template/spec/containers/0/resources"}])
	count(deny) > 0 with input as bad
}

test_root_pod_denied if {
	bad := json.patch(good, [{"op": "replace", "path": "/spec/template/spec/securityContext/runAsNonRoot", "value": false}])
	count(deny) > 0 with input as bad
}

test_latest_tag_denied if {
	bad := json.patch(good, [{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "ghcr.io/x/api:latest"}])
	count(deny) > 0 with input as bad
}
