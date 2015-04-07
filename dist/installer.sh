#!/usr/bin/expect

spawn "./csgoserver install"

expect "Continue [y/N]"
send "y "

expect "Was the install successful? [y/N]"
send "y "

interact