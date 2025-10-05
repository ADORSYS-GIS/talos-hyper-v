variable "talos_version" {
  type        = string
  description = "The version of Talos to use."
}

variable "talos_extensions" {
  type        = list(string)
  default     = []
  description = "A list of Talos extensions to include in the image."
}