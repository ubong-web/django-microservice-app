from celery import shared_task
import time

@shared_task(bind=True)
def process_data(self, email, message):
    time.sleep(10)
    result = f"Processed for {email} with message: {message}"
    print(result)
    return result
