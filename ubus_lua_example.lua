#!/usr/bin/env lua

require "ubus"
require "uloop"

-- uloop init
print("uloop init...\n")
uloop.init()

-- connect to ubus
print("connect to ubus...\n")
local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

-- util function to print table 
function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


-- objects to register to ubus
local my_method = {
	test = {
		-- hello function
		-- id is a interger argment
		-- msg is a string message
		-- return {"message":"foo"}
		hello = {
			function(req, msg)
				conn:reply(req, {message="foo"});
				print("Call to function 'hello'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
				end
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
	}
}
-- view object
print("view object ...")
print_r(my_method)

-- add object to ubus 
print("add object to ubus...")
conn:add(my_method)



print("\n\n");


-- init listen event
local my_event = {
	["DS.GREENPOWER"] = function(msg) 
		print("----------------------------------------")
		print("receive message sendded to GREENPOWER")
                for k, v in pairs(msg) do
        	        print("key=" .. k .. " value=" .. tostring(v))
          	end
	end,
	["DS.GATEWAY"] = function(msg) 
		print("----------------------------------------")
		print("receive message sendded to GATEWAY(mqtt)")
                for k, v in pairs(msg) do
        	        print("key=" .. k .. " value=" .. tostring(v))
          	end
	end,
}

-- view listern pattern table
print("view listen pattern...")
print_r(my_event)


-- start listen 
-- you can use ubus command to test listen like this:  ubus send DS.GREENPOWER '{"str":"helloworld","interger":1}'
print("add listen pattern to ubus listenner, you can use " .. '[ubus send DS.GREENPOWER {"str":"helloworld", "interger":1}]' .. " to send test message")
conn:listen(my_event)



-- send test message to ubus
print("\n\n")
print("send test message to ubus");
conn:send("DS.GREENPOWER", { str="helloworld", interger=1})


-- main loop
uloop.run()
