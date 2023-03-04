--[[
    Token format:
    type: <TokenType>
    value: <any>
--]]

-- Token class
local token = {}
token.__index = token

function token.new(type, value)
    return setmetatable({
        ["type"] = type,
        ["value"] = value
    }, {__index = token})
end

-- Token list class
local index = 1

-- 15 + 10 - 14 + 32 * 2 * 19

local tokens_list = {
    token.new("number", 15),
    token.new("binop", '+'),
    token.new("number", 10),
    token.new("binop", '-'),
    token.new("number", 14),
    token.new("binop", '+'),
    token.new("number", 32),
    token.new("binop", '*'),
    token.new("number", 2),
    token.new("binop", '*'),
    token.new("number", 19)
}


-- Shunting yard wikipedia example
--[[
local tokens_list = {
    token.new("number", 1),
    token.new("binop", '+'),
    token.new("number", 2),
    token.new("binop", '*'),
    token.new("number", 3),
    token.new("binop", '-'),
    token.new("number", 4)
}
--]]


function tokens_list:get_current()
    return tokens_list[index]
end

function tokens_list:consume(unsafe)
    local old = tokens_list[index]
    index = index + 1

    if not unsafe then
        if index > #tokens_list then
            index = #tokens_list
        end
    end

    return old
end

function tokens_list:peek_next()
    return tokens_list[index + 1]
end

-- Visitors for Nodes
local visitors = {
    ["number_expr"] = function(self)
        return self.value
    end,
    ["binary_expr"] = function(self)
        local res_1 = self.left:visit()
        local res_2 = self.right:visit()
        print("(", res_1, self.operator, res_2, ")")
        if self.operator == "+" then
            return res_1 + res_2
        elseif self.operator == "-" then
            return res_1 - res_2
        elseif self.operator == "*" then
            return res_1 * res_2
        elseif self.operator == "/" then
            return res_1 / res_2
        end
    end
}
visitors.__index = visitors

-- Node class
local node = {}
node.__index = node

function node.new(type, left, right)
    return setmetatable({
        ["visit"] = visitors[type],
        ["left"] = left,
        ["right"] = right
    }, {__index = node})
end


-- Basic recursive descent parser with slight modifications for reparenting to avoid infinite recursion.
-- This parser is a LL parser.
function tail_recursive_parser(tokens)
    local function eval_primary()
        local primary = tokens:consume()
        if primary.type ~= "number" then
            error("Unexpected token type: ", primary.type)
        end

        local number_expr = node.new("number_expr")
        number_expr.value = primary.value

        return number_expr
    end

    local function eval_multiplicatives()
        local left = eval_primary()
        
        while tokens:get_current().value == '*' or tokens:get_current().value == '/' do
            local operator = tokens:consume().value
            local new = node.new("binary_expr", left, eval_primary())
            new.operator = operator
            left = new
        end

        return left
    end

    local function eval_additives()
        local left = eval_multiplicatives()
        
        while tokens:get_current().value == '+' or tokens:get_current().value == '-' do
            local operator = tokens:consume().value
            local new = node.new("binary_expr", left, eval_multiplicatives())
            new.operator = operator
            left = new
        end

        return left
    end

    local function eval()
        return eval_additives()
    end

    return eval()
end

--print("result:", tail_recursive_parser(tokens_list):visit())


-- Shunting yard algorithm which is an LR parser.
-- This method converts the expression to a stack format in RPN (reverse polish notation) for ease of reading to the computer
--[[
    total = 0 | 1 2 3 * + 4 -
    total = 6 | 1 + 4 -
    total = 7 | 4 -
    total = 3 | empty
    done

    total = 0 | 1 7 *
    total = 7 | empty
    done
--]]

function shunting_yard(tokens)
    local output = {}
    local stack = {}
    local stack_size = #stack

    -- Setup stack methods used by shunting yard.
    function stack:push(obj)
        table.insert(stack, obj)
        stack_size = #stack
    end

    function stack:pop()
        local obj = stack[stack_size]
        table.remove(stack, stack_size)
        stack_size = #stack

        return obj
    end

    function stack:top()
        local obj = stack[stack_size]
        

        return obj
    end

    function get_precedence(operator_tok)
        local val = operator_tok.value
        if val == '+' or val == '-' then return 1
        elseif val == '*' or val == '/' then return 2
        else
            print("unknwon value:", val)
        end
    end

    function get_associative_index(operator_tok)
        local val = operator_tok.value
        if val == "+" or val == "*" then return 2
        elseif val == "-" or val == "/" then return 1
        else
            print("unknown associative:", val)
        end
    end

    local current_token = tokens_list:consume(true)
    while current_token do
        print("processing...", current_token.value)
        if current_token.type == 'binop' then
            while true do
                if not stack:top() then
                    break
                end
                if (get_precedence(stack:top()) > get_precedence(current_token)) or ((get_precedence(stack:top()) == get_precedence(current_token)) and (get_associative_index(current_token) > get_associative_index(stack:top()))) then
                    table.insert(output, stack:pop())
                else
                    break
                end
            end
            stack:push(current_token)
        else
            table.insert(output, current_token)
        end

        current_token = tokens_list:consume(true)
    end
    
    while true do
        local current = stack:pop()
        if current then
            table.insert(output, current)
        else
            break
        end
    end

    print("done reformatting the equation.")

    local str = ""
    for _, tok in output do
        str = str .. tok.value .. " "
    end

    print("solving:", str)
    local stack = {}

    for i = #output, 1, -1 do
        table.insert(stack, output[i])
    end

    function solve(operator, a, b)
        if operator == "+" then
            return a + b
        elseif operator == "-" then
            return a - b
        elseif operator == "*" then
            return a * b
        elseif operator == "/" then
            return a / b
        end
    end
    
    while #stack ~= 1 do
        for i = #stack, 1, -1 do
            local current = stack[i]
            print(current.value, current.type)
            if current.type == "binop" then
                local operator = current.value
                local va = stack[i+2].value
                local vb = stack[i+1].value
    
                total = solve(operator, va, vb)
    
                table.remove(stack, i)
                table.remove(stack, i)
                stack[i] = token.new("number", total) -- update total value onto stack
                break
            end
        end
    end

    print("shunting yard result:", total)
end

shunting_yard(tokens_list)
