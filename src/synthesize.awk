#! /usr/bin/env awk -f

{
    line = $0
    
    if (line ~ /@property/) {
        #start-fragment body
        readSynthesizers(line, synthesizers)
        reformatSynthesizers(synthesizers)
        #end-fragment body
    }
}