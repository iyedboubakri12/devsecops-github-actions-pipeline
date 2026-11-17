# Policy-as-Code checked by Conftest on the rendered Helm manifests.
package main

import rego.v1

containers contains c if {
	input.kind == "Deployment"
	some c in input.spec.template.spec.containers
}

deny contains msg if {
	some c in containers
	not c.resources.limits.cpu
	msg := sprintf("container %q must set a CPU limit", [c.name])
}

deny contains msg if {
	some c in containers
	not c.resources.limits.memory
	msg := sprintf("container %q must set a memory limit", [c.name])
}

deny contains msg if {
	input.kind == "Deployment"
	not input.spec.template.spec.securityContext.runAsNonRoot
	msg := "pods must run as non-root (spec.template.spec.securityContext.runAsNonRoot)"
}

deny contains msg if {
	some c in containers
	c.securityContext.privileged
	msg := sprintf("container %q must not be privileged", [c.name])
}

deny contains msg if {
	some c in containers
	not c.securityContext.readOnlyRootFilesystem
	msg := sprintf("container %q must use a read-only root filesystem", [c.name])
}

deny contains msg if {
	some c in containers
	endswith(c.image, ":latest")
	msg := sprintf("container %q uses the mutable :latest tag", [c.name])
}
