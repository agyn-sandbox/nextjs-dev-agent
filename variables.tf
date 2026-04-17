variable "api_url" {
  type        = string
  description = "Agyn Gateway URL"
  default     = "https://gateway.agyn.dev:2496"
}

variable "organization_id" {
  description = "ID of the Agyn organization"
  type        = string
}

variable "api_token" {
  description = "API Token"
  type        = string
}


variable "llm_provider_endpoint" {
  description = "LLM provider endpoint"
  type        = string
  default     = "https://api.openai.com/v1/responses"
}

variable "llm_provider_token" {
  description = "LLM provider token"
  type        = string
  sensitive   = true
}
