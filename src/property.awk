#! /usr/bin/env awk -f

{
    line = $0
    
    if (line ~ /@property/) {
        # @fragment body
        readProperties(line, properties)
        reformatProperties(properties)
        # @end body
    }
}