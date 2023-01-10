output "invoke_url" {
  description = "Invoke URL"
  value       = aws_api_gateway_stage.gw_stage.invoke_url
}