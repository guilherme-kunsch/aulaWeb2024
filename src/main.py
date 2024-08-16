from diagrams import Diagram
from diagrams.aws.compute import Lambda, ECS
from diagrams.aws.network import APIGateway
from diagrams.aws.storage import S3
from diagrams.aws.integration import SQS
from diagrams.aws.database import RDS
from diagrams.generic.device import Mobile

with Diagram("Sistema de Cálculo de Frete - Arquitetura Completa", show=True):
    # Componentes
    cliente = Mobile("Cliente")  # Usando Mobile para representar o cliente
    api_gateway = APIGateway("API Gateway")
    marketplace = Lambda("Marketplace")
    hub = ECS("HUB")  # Substituindo Lambda por ECS
    transportadora = Lambda("Transportadora")
    
    db_orders = RDS("Banco de Dados de Pedidos")
    db_quotes = RDS("Banco de Dados de Cotações")
    
    queue = SQS("Fila de Mensagens")
    storage = S3("Armazenamento de Cotações")

    # Conexões
    cliente >> api_gateway >> marketplace
    marketplace >> db_orders
    marketplace >> queue
    queue >> hub
    hub >> transportadora
    transportadora >> storage
    hub >> db_quotes
    hub >> marketplace
    marketplace >> api_gateway >> cliente
