# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import base64
import json
import os
import unittest
from unittest.mock import patch, MagicMock

# Set environment variables before importing main
os.environ['SPANNER_INSTANCE'] = 'test-instance'
os.environ['SPANNER_DATABASE'] = 'test-database'

# Create a mock for google.cloud.spanner
mock_spanner = MagicMock()
# Apply the patch
patcher = patch.dict('sys.modules', {'google.cloud.spanner': mock_spanner, 'google.cloud': MagicMock()})
patcher.start()

import main

class TestCloudRunApp(unittest.TestCase):
    def setUp(self):
        self.app = main.app.test_client()
        self.app.testing = True

    def test_empty_payload(self):
        response = self.app.post('/', json={})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.text, 'Bad request')

    def test_missing_message(self):
        response = self.app.post('/', json={'not_message': 'here'})
        self.assertEqual(response.status_code, 400)

    @patch('main.upsert_membership')
    def test_add_group_member_event(self, mock_upsert):
        mock_log_data = {
            'protoPayload': {
                'metadata': {
                    'event': {
                        'eventName': 'ADD_GROUP_MEMBER',
                        'parameter': [
                            {'name': 'USER_EMAIL', 'value': 'user@example.com'},
                            {'name': 'GROUP_EMAIL', 'value': 'group@example.com'}
                        ]
                    }
                }
            }
        }
        encoded_data = base64.b64encode(json.dumps(mock_log_data).encode('utf-8')).decode('utf-8')
        
        response = self.app.post('/', json={
            'message': {
                'data': encoded_data
            }
        })
        
        self.assertEqual(response.status_code, 200)
        mock_upsert.assert_called_once_with('user@example.com', 'group@example.com')

    @patch('main.upsert_permission')
    def test_set_iam_policy_event(self, mock_upsert):
        mock_log_data = {
            'protoPayload': {
                'methodName': 'SetIamPolicy',
                'resourceName': 'projects/my-project',
                'request': {
                    'policy': {
                        'bindings': [
                            {
                                'role': 'roles/viewer',
                                'members': ['group:viewers@example.com']
                            }
                        ]
                    }
                }
            }
        }
        encoded_data = base64.b64encode(json.dumps(mock_log_data).encode('utf-8')).decode('utf-8')
        
        response = self.app.post('/', json={
            'message': {
                'data': encoded_data
            }
        })
        
        self.assertEqual(response.status_code, 200)
        mock_upsert.assert_called_once_with('viewers@example.com', 'projects/my-project', 'roles/viewer')

if __name__ == '__main__':
    unittest.main()
