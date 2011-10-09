#! /usr/bin/env awk -f

{
    line = $0
    
    if (line ~ /@property/) {
        # @fragment body
        readSynthesizers(line, synthesizers)
        reformatSynthesizers(synthesizers)
        # @end body
    }
}