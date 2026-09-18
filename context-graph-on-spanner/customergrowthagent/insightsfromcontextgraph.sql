-- Copyright 2026 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

GRAPH MarketingContextGraph
MATCH (c:Customers {{industry: 'Manufacturing', tier: 'Gold'}})<-[:AboutCustomer]-(d:Decisions {{signal_type: 'LOW_ADOPTION'}})-[:ResultedIn]->(o:Outcomes)
WHERE o.result = 'Renewed'
RETURN 
  d.timestamp AS Date,
  d.decision_type AS Action_Type,
  d.reasoning_text AS Success_Logic
ORDER BY d.timestamp DESC
LIMIT 3
