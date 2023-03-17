from google.oauth2 import service_account
from googleapiclient.discovery import build
import json

# set up credentials and API client
credentials = service_account.Credentials.from_service_account_file('./service-account.json')
service = build('compute', 'v1', credentials=credentials)

# specify the project, zone, and instance name
project = 'sandbox-durgesh'
zone = 'us-central1-a'
instance_name = 'instance-1'

# fetch the instance metadata
request = service.instances().get(project=project, zone=zone, instance=instance_name)
response = request.execute()

# output the metadata in JSON format
print(json.dumps(response['metadata'], indent=2))

#if we want to fetch specific metadata based on key such as ssh-key, disks, image we can do it as below

print(response['metadata']['ssh-keys'])
print(response['metadata']['disks'])
