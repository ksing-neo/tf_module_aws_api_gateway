import boto3
import os
import json

# Send to SNS
def send_to_sns(alert):
    sns_client = boto3.client('sns')
    sns_arn = os.environ['sns_topic_arn']
    application = os.environ['application']

    snsbody = {
        'Application': application,
        'Error': str(alert)
    }

    sns_client.publish(TopicArn=sns_arn, Message=json.dumps(snsbody))

def main(event, context):

    print(f"Received event: {event}")

    identitySource = event.get('identitySource', '')

    if identitySource == os.environ['origin']:

        responsedata = {
            "principalId": "user",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Action": "execute-api:Invoke",
                        "Effect": "Allow",
                        "Resource": os.environ['api_arn']
                    }
                ]
            }
        }

    ## Include SNS to monitor unauthorized access
    ## Provide reply like the usage of this API is being monitored.
        
    else:
        responsedata = {
            "principalId": "user",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Action": "*",
                        "Effect": "Deny",
                        "Resource": "*"
                    }
                ]
            }
        }

        send_to_sns("Unauthorized access")

    print(f"Response data : {responsedata}")

    return responsedata