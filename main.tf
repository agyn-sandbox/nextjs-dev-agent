
resource "agyn_llm_provider" "openai" {
  organization_id = var.organization_id
  endpoint        = var.llm_provider_endpoint
  auth_method     = "bearer"
  token           = var.llm_provider_token
}

resource "agyn_model" "model" {
  organization_id = var.organization_id
  name            = "gpt-5.2"
  llm_provider_id = agyn_llm_provider.openai.id
  remote_name     = "gpt-5.2"
}

resource "agyn_agent" "dev" {
  organization_id = var.organization_id
  name            = "SuperDev"
  role            = "Engineer"
  nickname        = "dev"
  model           = agyn_model.model.id
  idle_timeout    = "10m"
  image           = "ghcr.io/agyn-sandbox/devcontainer-nextjs-demo:0.1.0"
  init_image      = "ghcr.io/agynio/agent-init-codex:0.13.14"
  # init_image = "ghcr.io/agynio/agent-init-claude:0.1.11"

  configuration = jsonencode({
    system_prompt = <<-PROMPT
      You are senior frontend engineer. You have nextjs app in /workspace/app. This is your working directory. 
      Devserver is already started and URL is shared with the user.
    PROMPT
  })
}

resource "agyn_init_script" "init" {
  agent_id = agyn_agent.dev.id
  script   = <<-SCRIPT
    cd /workspace
    npx create-next-app@latest app --yes
    cd app
    setsid npm run dev > /workspace/dev.log 2>&1 &

    URL=$(/agyn-bin/cli/agyn expose add 3000 -o json | jq -r .url)
    /agyn-bin/cli/agyn threads send --message "New environment preview url is: $URL"
  SCRIPT
}

resource "agyn_mcp" "files_mcp" {
  agent_id    = agyn_agent.dev.id
  name        = "files_mcp"
  image       = "ghcr.io/agynio/files-mcp:0.1.0"
  command     = "/app/files-mcp"
  description = "File access MCP — provides read_file tool"
}


resource "agyn_volume" "state" {
  organization_id = var.organization_id
  persistent      = true
  mount_path      = "/root"
  size            = "1Gi"
  description     = "agn thread persistence"
}

resource "agyn_volume_attachment" "state" {
  volume_id = agyn_volume.state.id
  agent_id  = agyn_agent.dev.id
}


resource "agyn_volume" "workspace" {
  organization_id = var.organization_id
  persistent      = true
  mount_path      = "/workspace"
  size            = "5Gi"
  description     = "workspace persistence"
}

resource "agyn_volume_attachment" "workspace" {
  volume_id = agyn_volume.workspace.id
  agent_id  = agyn_agent.dev.id
}
