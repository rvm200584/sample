cat > variables.tf << 'EOF'
variable "project_name" {
  default = "logicworks"
}

variable "notification_email" {
  default = "your-email@gmail.com"   # ← CHANGE THIS TO YOUR EMAIL
}
EOF
