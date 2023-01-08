output "users-table" {
  value       = aws_dynamodb_table.realworld-users-table
}

output "articles-table" {
  value       = aws_dynamodb_table.realworld-articles-table
}

output "comments-table" {
  value       = aws_dynamodb_table.realworld-comments-table
}