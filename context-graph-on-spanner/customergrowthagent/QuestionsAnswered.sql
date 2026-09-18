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

--When usage drops for a Gold Tier client, what intervention has the highest probability of a full-price renewal?
GRAPH MarketingContextGraph
MATCH (c:Customers {tier: 'Gold'})<-[:AboutCustomer]-(d:Decisions {signal_type: 'LOW_ADOPTION'})-[:ResultedIn]->(o:Outcomes)
WHERE o.result = 'Renewed'
RETURN 
  d.decision_type AS Intervention, 
  COUNT(*) AS Success_Count,
  AVG(o.revenue_impact) AS Avg_Revenue_Retained
GROUP BY Intervention
ORDER BY Success_Count DESC
LIMIT 1;

--Does a recommendation (e.g., deep discount) actually prevent churn, or does it simply delay it?
GRAPH MarketingContextGraph
MATCH (c:Customers)<-[:AboutCustomer]-(d:Decisions {decision_type: 'Discount'})-[:ResultedIn]->(o:Outcomes)
/* We check the results of those who received a discount */
RETURN 
  o.result AS Final_Status,
  COUNT(c.customer_id) AS Customer_Count,
  AVG(o.revenue_impact) AS Total_Financial_Impact
GROUP BY Final_Status;
