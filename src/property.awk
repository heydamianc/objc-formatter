#! /usr/bin/env awk -f

{
    line = $0
    
    if (line ~ /@property/) {
        #start-fragment body
        readProperties(line, properties)
        reformatProperties(properties)
        #end-fragment body
    }
}