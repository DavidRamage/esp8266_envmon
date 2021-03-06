WIFI_CONFIG = {}
WIFI_CONFIG.ssid = "MY_SSID"
WIFI_CONFIG.pwd = "MY_PASSWORD"
MAX_CONNECT_ATTEMPTS = 100
CONNECT_ATTEMPT = 0
PIN_18B20 = 4 
ADDR_18B20 = nil
TEMPERATURE = 0
COMMUNITY = "MY_COMMUNITY_STRING"
SYSLOCATION = "somewhere good"
VERSION = "Environment Monitor 0.01a"
SYSNAME  = "monitor1"
function make_oid_response(community, request_id)
    community_len = string.len(community)
    pack_str = '> I1 I1 I3 I2 c' .. community_len .. 'I4 I4 I2 I2 I2 I2 I2 I2 I4 I4 I2 I4 I4 I2'
    return struct.pack(pack_str, 0x30, 0x2D + community_len, 0x020100, 0x0409, community, 0xA2260204, request_id,
    0x0201, 0x0002, 0x0100, 0x3018, 0x3016, 0x0608, 0x2b060102, 0x01010200, 0x060A, 0x2B060104, 0x01BF0803, 0x020A)
end
function make_get_next_response_sysname(community, request_id, sysname)
   community_len = string.len(community)
   sysname_len = string.len(sysname)
   pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. community_len .. 'I1 I1 I1 I1 I4 I3 I3 I1 I1 I1 I1 I1 I1 I4 I2 I2 I1 I1 c' .. sysname_len
   return struct.pack(pack_str, 0x30, 0x23 + community_len + sysname_len, 0x02, 0x01, 0x00, 0x04, community_len, community,
   0xA2, 0x1C + sysname_len, 0x02, 0x04, request_id, 0x020100, 0x020100, 0x30, 0x0E + sysname_len, 0x30,
   0x0C + sysname_len, 0x06, sysname_len -3, 0x2b060102, 0x0101, 0x0500, 0x04, sysname_len,
   sysname)
end
function make_get_sysname_response(sysname, comm_len, community, request_id, varbind, obj_hi, obj_lo)
    sysname_len = string.len(sysname)
    community_len = string.len(community)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I2 I4 I4 I1 I1 c' .. sysname_len
    return struct.pack(pack_str, 0x30, 0x23 + sysname_len + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
        community, 0xA2, 0x1C + sysname_len, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02,
        0x01, 0x00, 0x30, 0x0E + sysname_len, 0x30, 0x0C + sysname_len, varbind, obj_hi, obj_lo, 0x04, sysname_len, sysname)
end
function make_temperature_value_response(comm_len, community, request_id)
    community_len = string.len(community)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 i2'
    return struct.pack(pack_str, 0x30, 0x2A + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
    community, 0xA2, 0x23, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x15, 0x30, 0x13, 0x06, 0x0d, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x8f, 0x65, 0x0d, 0x10,
    0x02, 0x01, 0x03, 0x0d, 0x42, 0x02, TEMPERATURE)
end
function make_temperature_integer_response(comm_len, community, request_id)
    community_len = string.len(community)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1'
    return struct.pack(pack_str, 0x30, 0x29 + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
    community, 0xA2, 0x22, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x14, 0x30, 0x12, 0x06, 0x0d, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x8f, 0x65, 0x0d, 0x10,
    0x02, 0x01, 0x01, 0x0d, 0x02, 0x01, 0x0d, 0x01, 0x0d)

end
function make_get_temp_name_response(temp_name, comm_len, community, request_id, varbind, obj_hi, obj_lo)
    tempname_len = string.len(temp_name)
    community_len = string.len(community)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I2 I1 I1 I4 I1 I1 I4 I1 I1 I1 c' .. tempname_len
    return struct.pack(pack_str, 0x30, 0x28 + tempname_len + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
        community, 0xA2, 0x21 + tempname_len, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02,
        0x01, 0x00, 0x30, 0x13 + tempname_len, 0x30, 0x11 + tempname_len, varbind, 0x2b, 0x06, obj_hi, 0x65, 0x0d, obj_lo, 0x0d, 0x04, tempname_len, temp_name)
end

function make_snmp_unpackstring(data)
    asn_header, pdu_len, version, comm_name, comm_len, excess = struct.unpack('> I1 I1 I3 I1 I1 s', data)  
    if (string.len(data) == (37 + string.len(COMMUNITY))) then
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. 'I1 I1 I2 I4 I8 I2 I2 I4 I4'
        return output_str
    elseif (string.len(data) == (42 + string.len(COMMUNITY))) then
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. ' I2 I2 I4 I8 I2 I2 I6 I6 I3'
        return output_str
    elseif (string.len(data) == (34 + string.len(COMMUNITY))) then
        output_str = '> I1 I1 I1 I4 c' .. comm_len .. 'I4 I4 I8 I4 I4 I3'
        return output_str
    elseif (string.len(data) == (38 + string.len(COMMUNITY))) then
        output_str = '>  I1 I1 I3 I1 I1 c' .. comm_len .. 'I4 I4 I2 I1 I2 I1 I4 I4 I4 I4'
        return output_str
    elseif (string.len(data) == (40 + string.len(COMMUNITY))) then
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len .. 'I2 I2 I4 I10 I4 I4 I4 I3'
        return output_str
    elseif (string.len(data) == (41 + string.len(COMMUNITY))) then
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len .. 'I2 I2 I4 I10 I4 I4 I4 I3'
        return output_str
    else
        return nil
    end
end
function start_server()
   print("starting the server")
   udpSocket = net:createUDPSocket()
   udpSocket:listen(161, ip_address)
   udpSocket:on("receive", function(s, data, port, ip)
      if (string.len(data) == (37 + string.len(COMMUNITY))) then 
      snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, version, comm_name, comm_len, comm_string, req_type, req_len, dgaf1, req_id, dgaf2, varbind_list, varbind, obj_hi, obj_lo = struct.unpack(snmp_unpackstr, data)
        if (obj_hi == 0x2b060102 and obj_lo == 0x1010500) then
          -- 1.3.6.1.2.1.1.5.0 - sysname
          if  req_type == 0xa1 then
            return_str = make_get_sysname_response(SYSLOCATION, comm_len, comm_string, req_id, varbind, 0x2b060102, 0x1010600)
            s:send(port, ip, return_str)
          else
            print("Calling make_get_sysname_response")
            return_str = make_get_sysname_response(SYSNAME, comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
            s:send(port, ip, return_str)
          end
        elseif (obj_hi == 0x2b060102 and obj_lo == 0x1010600 and req_type == 0xa0) then
          -- 1.3.6.1.2.1.1.6.0 - syslocation
          return_str = make_get_sysname_response(SYSLOCATION, comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
          s:send(port, ip, return_str)
        elseif (obj_hi == 0x2b060102 and obj_lo == 0x1010100 and req_type == 0xa0) then
          -- 1.3.6.1.2.1.1.1.0 - os
          return_str = make_get_sysname_response(VERSION, comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
          s:send(port, ip, return_str)
        elseif (obj_hi == 0x2b060102 and obj_lo == 0x1010200 and req_type == 0xa0) then
          return_str = make_oid_response( comm_string, req_id)
          s:send(port, ip, return_str)
        end
      elseif (string.len(data) == (41 + string.len(COMMUNITY))) then
        snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, version, comm_name, comm_len, comm_string, req_type, dgaf1, req_id, dgaf2, varbind_list, varbind, obj_hi, obj_lo, obj_really_low = struct.unpack(snmp_unpackstr, data)
        if (req_type == 0x0a120) then
            if (obj_hi == 0x650d1002 and obj_lo == 0x10105 and obj_really_low == 0x32) then
                return_str = make_temperature_integer_response(comm_len, comm_string, req_id)
                s:send(port, ip, return_str)
            elseif (obj_hi == 0x650d1002 and obj_lo == 0x10205 and obj_really_low == 0x32) then
                -- varbind is the problem
                return_str = make_get_temp_name_response('Ambient', comm_len, comm_string, req_id, 0x3018060d, 0x104018f, 0x10020102)
                s:send(port, ip, return_str)
            elseif (obj_hi == 0x650d1002 and obj_lo == 0x10305 and obj_really_low == 0x32) then
                GET_18B20_TEMP()
                return_str = make_temperature_value_response(comm_len, comm_string, req_id)
                s:send(port, ip, return_str)
            end
        end
      elseif (string.len(data) == (42 + string.len(COMMUNITY))) then
        snmp_unpackstr = make_snmp_unpackstring(data)
        -- output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. ' I1 I1 I2 I4 I8 I2 I2 I6 I6 I3'
        asn_header, pdu_len, version, comm_name, comm_len, comm_string, req_type, dgaf1, req_id, dgaf2, varbind_list, varbind, obj_hi, obj_lo, obj_really_low = struct.unpack(snmp_unpackstr, data)
            if (obj_hi == 0x104018f and obj_lo == 0x10020101) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.1.13
                if (req_type == 0xa021) then
                    return_str = make_temperature_integer_response(comm_len, comm_string, req_id)
                    s:send(port, ip, return_str)
                elseif (req_type == 0xa121) then
                    return_str = make_get_temp_name_response('Ambient', comm_len, comm_string, req_id, varbind, 0x104018f, 0x10020102)
                    s:send(port, ip, return_str)
                end
            elseif (obj_hi == 0x104018f and obj_lo == 0x10020103) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.3.13
              if (req_type == 0xa021 or (req_type == 0xa121 and obj_really_low == 0x32)) then
                GET_18B20_TEMP()
                return_str = make_temperature_value_response(comm_len, comm_string, req_id)
                s:send(port, ip, return_str)
              end
            elseif (obj_hi == 0x104018f and obj_lo == 0x10020102) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.2.13 
              if (req_type == 0xa021) then
                return_str = make_get_temp_name_response('Ambient', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
                s:send(port, ip, return_str)
              elseif (req_type == 0xa121) then
                GET_18B20_TEMP()
                return_str = make_temperature_value_response(comm_len, comm_string, req_id)
                s:send(port, ip, return_str)
              end
            end
      elseif (string.len(data) == (34 + string.len(COMMUNITY))) then
        snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, small_stuff, stuff, community_str, something, request_id, error_data, varbind_hi, varbind_lo, varbind_bottom = struct.unpack(snmp_unpackstr, data)
        if (varbind_hi == 0x30090605 and varbind_lo == 0x2b060102 and varbind_bottom == 0x10500) then
            print("calling make_get_next_response_sysname")
            return_str = make_get_next_response_sysname(community_str, request_id, SYSNAME)
            s:send(port, ip, return_str)
        end
      elseif (string.len(data) == (38 + string.len(COMMUNITY))) then
        snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, small_stuff, stuff, other_stuff, community_str, req_type, req_id, placeholder_1, error_status, placeholder_2, error_index, placeholder_3, obj_hi, obj_mid, obj_lo = struct.unpack(snmp_unpackstr, data)
        if (req_type ==  0xa11d0204 and obj_hi == 0x06092b06 and obj_mid == 0x0104018f and obj_lo == 0x0650d1005) then
              return_str = make_temperature_integer_response(other_stuff, community_str, req_id)
              s:send(port, ip, return_str)
        end
      elseif (string.len(data) == (40 + string.len(COMMUNITY))) then
        --length of a getnext for 1.3.6.1.4.1.2021.13.16.2.1
        snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, small_stuff, stuff, other_stuff, community_str, req_type, nonsense, req_id, nonsense, obj_hi, obj_med, obj_lo, obj_bottom = struct.unpack(snmp_unpackstr, data)
        if (obj_hi == 0x60b2b06 and obj_med == 0x104018f and obj_lo == 0x650d1002 and obj_bottom == 0x10500) then
            return_str = make_temperature_integer_response(string.len(community_str), community_str, req_id)
            s:send(port, ip, return_str)
        end
      end
	end)
end

function check_connection()
    if( CONNECT_ATTEMPT > MAX_CONNECT_ATTEMPTS) then
        print("failed to connect to wifi!")
    else
        CONNECT_ATTEMPT = CONNECT_ATTEMPT + 1
        ip_address = wifi.sta.getip()
        if ((ip_address ~= nil) and (ip_address ~= '0.0.0.0')) then
            print(ip_address)
            start_server()
        else
            print("not on the wifi just yet")
            tmr.alarm(0,2500,0,check_connection) 
        end
    end
end
function GET_18B20_TEMP()
    ow.reset(PIN_18B20)
    ow.select(PIN_18B20, ADDR_18B20)
    ow.write(PIN_18B20, 0x44, 1)
    tmr.delay(1000000)
    present = ow.reset(PIN_18B20)
    ow.select(PIN_18B20, ADDR_18B20)
    ow.write(PIN_18B20,0xBE,1)
    data = nil
    data = string.char(ow.read(PIN_18B20))
    for i = 1, 8 do
        data = data .. string.char(ow.read(PIN_18B20))
    end
    crc = ow.crc8(string.sub(data,1,8))
    if crc == data:byte(9) then
       t = (data:byte(1) + data:byte(2) * 256) * 625
       TEMPERATURE = t / 10
       t1 = t / 10000
    end
end
function INIT_18B20()
    ow.setup(PIN_18B20)
    count = 0
    repeat
        count = count + 1
        addr = ow.reset_search(PIN_18B20)
        addr = ow.search(PIN_18B20)
        tmr.wdclr()
    until (addr ~= nil) or (count > 100)
    if addr == nil then
        print("No more addresses.")
    else
        print(addr:byte(1,8))
    end
    crc = ow.crc8(string.sub(addr,1,7))
    if crc == addr:byte(8) then
        ADDR_18B20 = addr
        GET_18B20_TEMP()
    end
end
print("Starting system")
ip_address = wifi.sta.getip()
INIT_18B20()
if ((ip_address ~= nil) and (ip_address ~= '0.0.0.0')) then
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_CONFIG)
else
    tmr.alarm(0,2500,0,check_connection) 
end
