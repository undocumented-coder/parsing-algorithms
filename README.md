# parsing-algorithms
Basic algorithms for parsers written in luau
https://github.com/Roblox/luau

luau is an extent of lua with a nicer and more sandboxed environment than regular vanilla lua.

This repository holds basic parsing algorithms I wrote for math. The operators they support are + - * /
They can support parenthesis if you add onto them but I am making rough drafts for each parser design.

Both implementations will work out of the box, don't run both at the same time because they derive from the same token list. Just uncomment the parts where they are called for usage.

# Overview:
# Tail Recursive Parser 
This kind of parser is a parser which uses LL (as opposed to LR) for parsing mathematics (and other things).
This parser operates on AST in my example.
This kind of parser is a top-down parser. https://en.wikipedia.org/wiki/Top-down_parsing
# Shunting Yard Parser
This kind of parser is more strict and limited than the tail recursive parser. It is commonly used in calculators and is based on a stack (convertable to AST).
This parser is a bottom-up parser (LR).
