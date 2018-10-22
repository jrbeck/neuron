import requests
import json

# r = requests.get('https://api.github.com/user', auth=('user', 'pass'))
response = requests.get('http://localhost:3000/test')
response_json = json.loads(response.text)
print(response.text)
print(response_json)
print(response_json['name'])
# r.status_code
# print(response.headers['content-type'])
# r.encoding
# r.text
# r.json()
