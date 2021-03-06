// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import MobiusCore

public struct UpdateSpec<Types: LoopTypes> {
    public typealias Model = Types.Model
    public typealias Event = Types.Event
    public typealias Effect = Types.Effect

    public typealias Assert = (Result) -> Void

    private let update: Update<Types>

    public init(_ update: @escaping Update<Types>) {
        self.update = update
    }

    public func given(_ model: Model) -> When {
        return When(update, model)
    }

    public struct When {
        private let update: Update<Types>
        private let model: Model

        init(_ update: @escaping Update<Types>, _ model: Model) {
            self.update = update
            self.model = model
        }

        public func when(_ event: Event, _ moreEvents: Event...) -> Then {
            return Then(update, model, [event] + moreEvents)
        }
    }

    public struct Then {
        private let update: Update<Types>
        private let model: Model
        private let events: [Event]

        init(_ update: @escaping Update<Types>, _ model: Model, _ events: [Event]) {
            self.update = update
            self.model = model
            self.events = events
        }

        public func then(_ expression: Assert) {
            var lastNext: Next<Model, Effect>?
            var lastModel = model

            for event in events {
                lastNext = update(lastModel, event)
                lastModel = lastNext?.model ?? lastModel
            }

            // there will always be at least one event, so lastNext is guaranteed to have a value
            expression(Result(model: lastModel, lastNext: lastNext!))
        }
    }

    public struct Result {
        public let model: Model
        public let lastNext: Next<Model, Effect>
    }
}
