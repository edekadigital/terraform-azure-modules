# this file defines stub terraform providers used for validating the source code.
# this is necessary because f.e. an empty azurem provider is not valid...
# in real life, the provider is defined outside and just used in the module.
# this file is copied into the src module before running `terraform validate`.

provider "azurerm" {
  features {}
}
