output "dynamodb_table_name" {
  value = aws_dynamodb_table.colours_table.name
}

output "palettes_table_name" {
  value = aws_dynamodb_table.palettes_table.name
}
