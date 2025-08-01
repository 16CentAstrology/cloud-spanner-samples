#! /usr/bin/env python
# Copyright 2025 Google LLC
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


from dataclasses import dataclass
import csv
import typing


@dataclass
class Station:
    id: int
    name: str
    latitude: float
    longitude: float

    def __init__(self, station):
        self.id = int(station["id"])
        self.name = station["station"]
        self.latitude = float(station["latitude"])
        self.longitude = float(station["longitude"])


@dataclass
class Stations:
    list_items: list[Station]

    def __init__(self):
        with open("data/station.csv") as f:
            reader = csv.DictReader(f)
            self.list_items = [Station(row) for row in reader]


@dataclass
class Route:
    id: int
    to_station: int
    distance: float
    time: float

    def __init__(self, route):
        self.id = int(route["from"])
        self.to_station = int(route["to"])
        self.distance = float(route["distance"])
        self.time = float(route["time"])


@dataclass
class Routes:
    list_items: list[Route]

    def __init__(self):
        with open("data/transit_edge.csv") as f:
            reader = csv.DictReader(f)
            self.list_items = [Route(row) for row in reader]


@dataclass
class ShortestRoute:
    from_station: int
    to_station: int
    hops: int
    distance: float
    time: float

    def __init__(self, route):
        self.from_station = int(route["start_id"])
        self.to_station = int(route["end_id"])
        self.hops = int(route["hops"])
        self.distance = float(route["distance"])
        self.time = float(route["time"])


@dataclass
class ShortestRoutes:
    list_items: list[ShortestRoute]

    def __init__(self, fromCsv=True):
        if fromCsv:
            with open("data/shortest_path.csv") as f:
                reader = csv.DictReader(f)
                self.list_items = [ShortestRoute(row) for row in reader]

    def split(self, n):
        res = []
        for i in range(0, len(self.list_items), n):
            res.append(self.list_items[i : i + n])
        return res
