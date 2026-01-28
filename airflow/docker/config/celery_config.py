import os

from airflow.providers.celery.executors.default_celery import DEFAULT_CELERY_CONFIG

# Customized configurations for Celery workers to work with AWS SQS
CELERY_CONFIG = {
    **DEFAULT_CELERY_CONFIG,
    "broker_transport_options": {
        **DEFAULT_CELERY_CONFIG["broker_transport_options"],
        # Ref: https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/sqs.html#predefined-queues
        "predefined_queues": {
            "default": {
                "url": os.getenv("X_AIRFLOW_CELERY_SQS_BROKER_PREDEFINED_QUEUE_URL")
            },
        },
    },
    "polling_interval": 1.0,
    # Ref: https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/sqs.html#caveats
    "worker_enable_remote_control": False,
}
