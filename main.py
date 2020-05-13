import os

def lambda_handler(event, context):
    print(os.environ['greeting'])
    return "{}, Greetings from Lambda!".format(os.environ['greeting'])
