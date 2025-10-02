variable "host" {
  type        = string
  description = "IP or hostname of the Hyper-V host"
}

variable "port" {
  type        = number
  default     = 5986
  description = "WinRM port (5985 HTTP or 5986 HTTPS)"
}

variable "https" {
  type    = bool
  default = true
}

variable "use_ntlm" {
  type    = bool
  default = true
}

variable "user" {
  type        = string
  description = "User to authenticate as"
}

variable "password" {
  type      = string
  sensitive = true
}

variable "production" {
  type    = bool
  default = false
  description = "If true, enforce production checks (HTTPS required, cert thumbprint required)"
}

variable "cert_thumbprint" {
  type    = string
  default = ""
  description = "If production=true, pass certificate thumbprint used by HTTPS listener"
}