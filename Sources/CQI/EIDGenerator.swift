//
//  EIDGenerator.swift
//  EIDGenerator
//
//  Created by Jason Jobe on 9/4/21.
//
// Inspired by FlakeMaker.swift
//  http://cutecoder.org
import Foundation

/// The EIDGenerator produces a process unique sequence of Int64
/// You can use it in lieu of UUID as a more compact and SQLite
/// compatable identifer
///
/// The generated Value is composed as follows
/// - 41 bits timestamp with custom epoch
/// - 12 bits sequence number
/// - 10 bits group ID
public class EIDGenerator {
    static let limitInstanceNumber = UInt16(0x400)
    
    var lastGenerateTime = Int64(0)
    var groupNumber : UInt16
    var sequenceNumber = UInt16(0)
    
    public init(groupNumber: Int) {
        self.groupNumber = UInt16(groupNumber % Int(EIDGenerator.limitInstanceNumber))
    }
    /**
     Generates the next identifier value.
     */
    public func nextValue(group: Int? = nil) -> Int64 {
        let now = Date.timeIntervalSinceReferenceDate
        var generateTime = Int64(floor( (now) * 1000) )
        
        let sequenceNumberMax = 0x1000
        
        if generateTime > lastGenerateTime {
            lastGenerateTime = generateTime
            sequenceNumber = 0
        } else {
            if generateTime < lastGenerateTime {
                // timestamp went backwards, probably because of NTP resync.
                // we need to keep the sequence number go forward
                generateTime = lastGenerateTime
            }
            sequenceNumber += 1
            if sequenceNumber == sequenceNumberMax {
                print ("WARNING: Sequence Overflow in \(#function)")
                sequenceNumber = 0
                // we overflowed the sequence number, bump the overflow into the time field
                generateTime += 1
                lastGenerateTime = generateTime
            }
        }
        
        /*
         Value is
         - 41 bits timestamp with custom epoch
         - 12 bits sequence number
         - 10 bits instance ID
         */
        
        let newGroup: UInt16
        if let group = group {
            newGroup = UInt16(group % Int(EIDGenerator.limitInstanceNumber))
        } else {
            newGroup = groupNumber
        }

        return (generateTime << 22)
        | (Int64(sequenceNumber & 0xFFF) << 10)
        | Int64(newGroup & (EIDGenerator.limitInstanceNumber-1))
    }
}

// MARK: Hashable

extension EIDGenerator: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lastGenerateTime)
        hasher.combine(groupNumber)
        hasher.combine(sequenceNumber)
    }
}

public func ==(lhs: EIDGenerator, rhs: EIDGenerator) -> Bool {
    return lhs.lastGenerateTime == rhs.lastGenerateTime && lhs.groupNumber == rhs.groupNumber && lhs.sequenceNumber == rhs.sequenceNumber
}

public struct EntityIDComponents {
    let value: Int64
    public init(_ value: Int64) {
        self.value = value
    }
    public var timestamp: Date {
        let time = ((value >> 22) / 1000)
        return Date(timeIntervalSinceReferenceDate: TimeInterval(time))
    }
    public var groupNumber: Int64 {
        (value << 54) >> 54
    }
    public var sequence: Int64 {
        (value << 41) >> 51
    }
}

extension EntityIDComponents: CustomStringConvertible {
    public var description: String {
        "EnityID (date: \(timestamp), group: \(groupNumber), seq: \(sequence))"
    }
}

