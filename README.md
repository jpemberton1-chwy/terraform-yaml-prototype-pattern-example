# The Prototype Pattern

There are lots of ways to handle configuration these days!

For example, VS Code uses CSON (CoffeeScript Object Notation); other editors use YAML.

Spring Boot has the option of using YAML or a proprietary configuration notation.

One way to make configuration data more readable, compact and maintainable is to use a pattern called "the prototype" pattern.

The "prototype" is a set of standard data that applies to all objects. Then, each object that inherits from the prototype overwrites any default values with its own value.

Many game engines can work with JSON and oftentimes use these data sets to configure enemies, player classes and items! In fact, some great examples of how to use the prototype pattern come from the games industry [(*Game Programming Patterns*, Nystrom, R., 2014)](https://www.amazon.com/Game-Programming-Patterns-Robert-Nystrom/dp/0990582906/ref=sr_1_1?crid=X2W9WMKO8VC7&keywords=game+programming+patterns&qid=1654275256&sprefix=game+programming+patterns%2Caps%2C104&sr=8-1).

Here's an example of how to utilize the pattern with YAML:

**Goblin Archer.yaml**
```yaml
name: Goblin Archer
prototype: Goblin
hp: 15
attack: 5
```

**Goblin.yaml**
```yaml
name: Goblin
hp: 10
mp: 0
attack: 3
defense: 1
magic_attack: 1
magic_defense: 1
```

When we merge **Goblin Archer** over the **Goblin** we get this object:

```yaml
name: Goblin Archer
hp: 15
mp: 0
attack: 5
defense: 1
magic_attack: 1
magic_defense: 1
```

## Example Use Cases

- Configuring many monitors with the same metadata (i.e. alert tags, vertical, metadata tags, renotify policies)
- Configuring many K8s services with similar defaults but allowing overrides
- Configuring many ECS tasks with similar defaults but allowing overrides
- Standardizing defaults for a Serverless Lambda project's functions but allowing the developer to configure additional functionality

## Terraform Usage

The easiest way to deeply merge a YAML files is to use the `cloudposse/utils` provider's [**utils_deep_merge_yaml**](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) data source like so:

```tf
terraform {
  required_providers {
    utils = {
      source  = "cloudposse/utils"
      version = "0.17.24"
    }
  }
}

data "utils_deep_merge_yaml" "configured_object" {
  for_each = fileset(path.module, "templates/prefix*.yaml")
  input = [
    file("${path.module}/templates/prototype.yaml"),
    file("${path.module}/${each.key}")
  ]
}
```

In this example `data.utils_deep_merge_yaml.configured_object` would be an instance of `map[string][interface{}]` where the key of the output map is the last file to be merged over the prototype.

Each file's map object contains a key for the `input`, `output` (the merged configuration, for example) and an `id`. (It also contains keys for the `utils_deep_merge_yaml` options `append_list` and `deep_copy_list`.)

In order to make use of the output within another set of configuration, you can simply use the `yamldecode` function to decode the YAML from the output into a map (e.g. configuring a set of hosted zones from templates).

## Running This Example

**Requirements**

- Terraform > 0.15.0

First, run:

```sh
terraform init
```

Then, run the following command:

```sh
terraform apply
```

Enter 'yes' to the prompt and then observe that files have been created in the `output` directory.

Feel free to play around with deeply nested values, lists and more!
