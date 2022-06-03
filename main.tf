terraform {
  required_providers {
    utils = {
      source  = "cloudposse/utils"
      version = "0.17.24"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

data "utils_deep_merge_yaml" "monitor" {
  for_each = fileset(path.module, "templates/ecs*.yaml")
  input = [
    file("${path.module}/templates/monitor_prototype.yaml"),
    file("${path.module}/${each.key}")
  ]
}

resource "local_file" "monitor" {
  for_each = data.utils_deep_merge_yaml.monitor
  filename = "${path.module}/output/${replace(each.key, "templates/", "")}"
  content  = each.value["output"]
}

