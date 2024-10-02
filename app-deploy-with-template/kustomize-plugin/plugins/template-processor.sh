#!/bin/bash
resourceList=$(cat) # read the `kind: ResourceList` from stdin

templatePath=$(echo "$resourceList" | yq e '.functionConfig.spec.templatePath' - )
templateParamsPath=$(echo "$resourceList" | yq e '.functionConfig.spec.templateParamsPath' - )
generateResources=$(oc process --local -f $templatePath --param-file $templateParamsPath -oyaml |  yq e '.items' - )

echo "
kind: ResourceList
items:
$generateResources
"
