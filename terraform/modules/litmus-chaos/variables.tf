variable "namespace" {
  description = "Kubernetes namespace where LitmusChaos will be installed"
  type        = string
  default     = "litmus"
}

variable "runtime_environment" {
  description = "Runtime environment"
  type        = string
}

variable "runtime_socket_path" {
  description = "Runtime environment socker path"
  type        = string
}
