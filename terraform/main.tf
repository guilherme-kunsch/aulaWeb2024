# Define o provedor AWS
provider "aws" {
  region = "us-west-2"  # Altere para a região desejada
}

# Recurso para o API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "api-gateway"
  description = "API Gateway para o sistema de cálculo de frete"
}

# Recurso para o Lambda Marketplace
resource "aws_lambda_function" "marketplace" {
  function_name = "marketplace"

  s3_bucket = "your-bucket-name" # Substitua pelo nome do seu bucket S3
  s3_key    = "lambda/marketplace.zip" # Substitua pelo caminho para o seu código

  handler = "index.handler"
  runtime = "nodejs14.x" # Altere conforme a sua necessidade
}

# Recurso para o Lambda Transportadora
resource "aws_lambda_function" "transportadora" {
  function_name = "transportadora"

  s3_bucket = "your-bucket-name" # Substitua pelo nome do seu bucket S3
  s3_key    = "lambda/transportadora.zip" # Substitua pelo caminho para o seu código

  handler = "index.handler"
  runtime = "nodejs14.x" # Altere conforme a sua necessidade
}

# Recurso para o ECS Cluster
resource "aws_ecs_cluster" "hub" {
  name = "hub-cluster"
}

# Recurso para o S3
resource "aws_s3_bucket" "storage" {
  bucket = "storage-bucket-name" # Substitua pelo nome do seu bucket
}

# Recurso para o SQS
resource "aws_sqs_queue" "queue" {
  name = "message-queue"
}

# Recurso para o RDS Orders
resource "aws_db_instance" "db_orders" {
  identifier        = "orders-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  name              = "orders"
  username          = "admin"
  password          = "your-password" # Substitua pela sua senha
  skip_final_snapshot = true
}

# Recurso para o RDS Quotes
resource "aws_db_instance" "db_quotes" {
  identifier        = "quotes-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  name              = "quotes"
  username          = "admin"
  password          = "your-password" # Substitua pela sua senha
  skip_final_snapshot = true
}

# Criação do mapeamento de API Gateway para Lambda Marketplace
resource "aws_api_gateway_integration" "marketplace_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = "POST"
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.marketplace.arn}/invocations"
}

# Criação do mapeamento de API Gateway para Lambda Transportadora
resource "aws_api_gateway_integration" "transportadora_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = "POST"
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.transportadora.arn}/invocations"
}

# Conectando o Lambda Marketplace ao API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.marketplace.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

# Conectando o Lambda Transportadora ao API Gateway
resource "aws_lambda_permission" "transportadora_api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transportadora.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

# Outputs
output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.api_gateway.execution_arn}"
}
