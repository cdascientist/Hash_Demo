' @module BGE
' Gets the number of lines in a string by counting the newlines
'
' @param {string} text
' @return {integer}
function BGE_getNumberOfLinesInAString(text as string) as integer
    lines = 1
    newLine = Chr(10)
    nextNewLineIndex = text.inStr(0, newLine)
    while nextNewLineIndex > - 1
        if nextNewLineIndex < text.len()
            lines++
            nextNewLineIndex = text.inStr(nextNewLineIndex + 1, newLine)
        else
            exit while
        end if
    end while
    return lines
end function

' Finds the index of the last time a substring appears in a string
'
' @param {string} text
' @param {string} substring
' @return {integer}
function BGE_lastInStr(text as string, substring as string) as integer
    nextLastIndex = text.inStr(0, substring)
    lastIndex = nextLastIndex
    while nextLastIndex > - 1
        lastIndex = nextLastIndex
        nextLastIndex = text.inStr(lastIndex + 1, substring)
    end while
    return lastIndex
end function

' Given a float number, returns the number with a fixed numbers of decimals as a string
'
' @param {float} num
' @param {integer} precision
' @return {string}
function BGE_numberToFixed(num as float, precision as integer) as string
    rounded = BGE_Math_Round(num, precision)
    numStr = rounded.toStr().trim()
    decimalIndex = BGE_lastInStr(numStr, ".")
    if - 1 = decimalIndex
        numStr += "." + string(precision, "0")
        return numStr
    end if
    afterDecimalCount = numStr.len() - 1 - decimalIndex
    if precision > afterDecimalCount
        numStr += string(precision - afterDecimalCount, "0")
    end if
    return numStr
end function'//# sourceMappingURL=./strings.bs.map