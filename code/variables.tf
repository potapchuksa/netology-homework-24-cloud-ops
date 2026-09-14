variable "auth_key_file" {
  type        = string
  description = "Path to or the contents of the Service Account file in JSON format"
  default = "~/.authorized_key.json"
}

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_key" {
  type        = string
}
