# UTF-8 Linter Demo #

## How to loop/check bytes ##
Two ways to handle signaling that a valid character was found:
- Print character and character bytes when a new start byte is found
  - Should handle errors gracefully
  - Have to handle outputting at the top of the block
- Print character and character bytes when all of the expected characters have
  been received
  - Should handle errors gracefully
  - Could possibly throw errors sooner, closer to where they would be occuring
  - Would catch errors where a new start byte is encountered in a place where
    it should not be

## What to output ##
- For valid and invalid bytes
  - Counter in the file where the bytes are found
  - Bytes in hexadecimal
- Byte-grouping character dumper
  - For each valid character, dump the bytes that make up that character
    surrounded by some kind of delimiter
    - `[12 34 56 78] [12 34 56 78] [12 34 56 78] [12 34 56 78]`
    - ` 12 34 56 78|12|34|56|78|12 34 56 78|12 34 56 78|`
    - ` 66|67|c2 a5|`


## Stream parsing of bytes ##
- Is the byte a valid start byte (for 1-byte, 2-byte, 3-byte or 4-byte UTF-8
  character)?
  - **YES**
    - Is there currently a character being processed?
      - **YES**
          - Throw an error
      - **NO**
        - Is the current start byte for a multi-byte character?
          - **NO**
            - Dump the byte to output
            - Reset `@valid_bytes`
            - Reset `$utf8_byte_counter`
            - Reset `$utf8_check_flag`
          - **YES**
            - Add the byte to `@valid_bytes`
            - Increment `$utf8_byte_conter`
            - Set `$utf8_check_flag` to whatever size bytes that are expected
              for the current character
  - **NO**
    - Are we in the middle of processing a character?
      - **YES**
        - Is the current byte a valid 'tail' byte 
        - **YES**
          - Is this the last expected byte for this character?
            - **YES** 
              - Dump the byte to output
              - Reset `@valid_bytes`
              - Reset `$utf8_byte_counter`
              - Reset `$utf8_check_flag`
            - **NO**
              - Add the byte to `@valid_bytes`
              - Increment `$utf8_byte_conter`
              - Set `$utf8_check_flag` to whatever size bytes that are expected
                for the current character
        - **NO**
          - Throw an error, tail byte encountered someplace where it shouldn't
            be
      - **NO**
        - Throw an error, tail byte encountered someplace where it shouldn't
          be


vim: filetype=markdown shiftwidth=2 tabstop=2
