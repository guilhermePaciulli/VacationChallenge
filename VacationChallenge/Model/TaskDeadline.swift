//
//  TaskDeadlineOptions.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 10/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import Foundation

class TaskDeadline {
    
    var title: String
    
    var hours: Int
    
    static public let options: [TaskDeadline] = [TaskDeadline(title: "1 hour",  hours: 1),
                                                 TaskDeadline(title: "2 hours", hours: 2),
                                                 TaskDeadline(title: "3 hours", hours: 3),
                                                 TaskDeadline(title: "4 hours", hours: 4),
                                                 TaskDeadline(title: "5 hours", hours: 5),
                                                 TaskDeadline(title: "6 hours", hours: 6),
                                                 TaskDeadline(title: "7 hours", hours: 7),
                                                 TaskDeadline(title: "1 day (8 hours)",   hours: 8),
                                                 TaskDeadline(title: "2 days (16 hours)", hours: 16),
                                                 TaskDeadline(title: "3 days (24 hours)", hours: 24),
                                                 TaskDeadline(title: "4 days (32 hours)", hours: 32),
                                                 TaskDeadline(title: "1 week (40 hours)",  hours: 40),
                                                 TaskDeadline(title: "2 weeks (80 hours)", hours: 80)]
    
    private init(title: String, hours: Int) {
        self.title = title
        self.hours = hours
    }
    
}
