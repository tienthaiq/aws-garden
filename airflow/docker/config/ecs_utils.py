import os

import httpx
from airflow.utils.net import get_host_ip_address


# In ECS container, both socket.fqdn() & socket.gethostbyname() return empty.
# This function gets container IP via ECS metadata URI.
# Ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint-v4-fargate.html
def get_ecs_host_ip_address():
    uri = os.getenv("ECS_CONTAINER_METADATA_URI_V4")
    if not uri:
        # Fallback to Airflow builtin
        return get_host_ip_address()

    res = httpx.get(uri)
    res.raise_for_status()
    payload = res.json()
    return payload["Networks"][0]["IPv4Addresses"][0]
