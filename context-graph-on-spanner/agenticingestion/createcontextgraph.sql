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

-- Node Tables
CREATE TABLE Customers (
  customer_id STRING(36) NOT NULL,
  name STRING(MAX),
  industry STRING(MAX),
  tier STRING(MAX),
  mrr FLOAT64,
) PRIMARY KEY (customer_id);

CREATE TABLE Decisions (
  decision_id STRING(MAX) NOT NULL,
  customer_id STRING(MAX) NOT NULL,
  signal_type STRING(MAX) NOT NULL,   -- e.g., 'LOW_ADOPTION', 'COMPETITOR_THREAT'
  decision_type STRING(MAX) NOT NULL, -- e.g., 'Strategic Advisory Workshop', 'Discount'
  reasoning_text STRING(MAX),        -- The Gemini-extracted summary
  timestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
) PRIMARY KEY (decision_id);

CREATE TABLE Policies (
  policy_id STRING(MAX) NOT NULL,
  name STRING(MAX),
  rule_definition STRING(MAX),
  is_active BOOL,
) PRIMARY KEY (policy_id);

CREATE TABLE Outcomes (
  outcome_id STRING(MAX) NOT NULL,
  result STRING(MAX),
  revenue_impact FLOAT64,
) PRIMARY KEY (outcome_id);

-- Edge Tables (Connections)
CREATE TABLE AboutCustomer (
  decision_id STRING(MAX) NOT NULL,
  customer_id STRING(36) NOT NULL,
) PRIMARY KEY (decision_id, customer_id),
  INTERLEAVE IN PARENT Decisions ON DELETE CASCADE;

CREATE TABLE FollowedPolicy (
  decision_id STRING(MAX) NOT NULL,
  policy_id STRING(MAX) NOT NULL,
) PRIMARY KEY (decision_id, policy_id),
  INTERLEAVE IN PARENT Decisions ON DELETE CASCADE;

CREATE TABLE ResultedIn (
  decision_id STRING(MAX) NOT NULL,
  outcome_id STRING(MAX) NOT NULL,
) PRIMARY KEY (decision_id, outcome_id),
  INTERLEAVE IN PARENT Decisions ON DELETE CASCADE;

CREATE PROPERTY GRAPH MarketingContextGraph
  NODE TABLES (
    Customers,
    Decisions,
    Policies,
    Outcomes
  )
  EDGE TABLES (
    AboutCustomer
      SOURCE KEY (decision_id) REFERENCES Decisions (decision_id)
      DESTINATION KEY (customer_id) REFERENCES Customers (customer_id),
    FollowedPolicy
      SOURCE KEY (decision_id) REFERENCES Decisions (decision_id)
      DESTINATION KEY (policy_id) REFERENCES Policies (policy_id),
    ResultedIn
      SOURCE KEY (decision_id) REFERENCES Decisions (decision_id)
      DESTINATION KEY (outcome_id) REFERENCES Outcomes (outcome_id)
  );
