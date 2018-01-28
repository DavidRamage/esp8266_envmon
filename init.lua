WIFI_CONFIG = {}
WIFI_CONFIG.ssid = "MY_SSID"
WIFI_CONFIG.pwd = "MY_PASSWORD"
MAX_CONNECT_ATTEMPTS = 100
CONNECT_ATTEMPT = 0
PIN_18B20 = 4 
ADDR_18B20 = nil
TEMPERATURE = 0
SNMP_WALK = false
function noop()
    return nil
end

function make_get_next_response_sysname(community, request_id, sysname)
   community_len = string.len(community)
   sysname_len = string.len(sysname)
   pack_str = '> I4 I1 I1 I1 c' .. community_len .. 'I4 I4 I3 I3 I1 I1 I1 I1 I1 I1 I4 I2 I2 I1 I1 c' .. sysname_len
   return struct.pack(pack_str, 0x30340201, 0x00, 0x04, community_len, community,
   0xA2240204, request_id, 0x020100, 0x020100, 0x30, 0x0E + sysname_len, 0x30,
   0x0C + sysname_len, 0x06, sysname_len, 0x2b060102, 0x0101, 0x0500, 0x04, sysname_len,
   sysname)
end

function make_temperature_value_response(comm_len, community, request_id)
    print("we sure are in the function!")
    print("comm_len" .. comm_len)
    print("community" .. community)
    print("request id" .. request_id)
    community_len = string.len(community)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 i2'
    return struct.pack(pack_str, 0x30, 0x2A + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
    community, 0xA2, 0x23, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02, 0x01,
    0x00, 0x30, 0x15, 0x30, 0x13, 0x06, 0x0d, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x8f, 0x65, 0x0d, 0x10,
    0x02, 0x01, 0x03, 0x0d, 0x42, 0x02, TEMPERATURE)
end

function make_temperature_integer_response(comm_len, community, request_id)
    print("comm_len" .. comm_len)
    print("community" .. community)
    print("request id" .. request_id)
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
    print(tempname_len)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I2 I1 I1 I4 I1 I1 I4 I1 I1 I1 c' .. tempname_len
    return struct.pack(pack_str, 0x30, 0x28 + tempname_len + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
        community, 0xA2, 0x21 + tempname_len, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02,
        0x01, 0x00, 0x30, 0x13 + tempname_len, 0x30, 0x11 + tempname_len, varbind, 0x02, 0x06, obj_hi, 0x65, 0x0d, obj_lo, 0x0d, 0x04, tempname_len, temp_name)
end

function make_get_sysname_response(sysname, comm_len, community, request_id, varbind, obj_hi, obj_lo)
    sysname_len = string.len(sysname)
    community_len = string.len(community)
    print(sysname_len)
    pack_str = '> I1 I1 I1 I1 I1 I1 I1 c' .. comm_len .. 'I1 I1 I1 I1 I4 I1 I1 I1 I1 I1 I1 I1 I1 I1 I1 I2 I4 I4 I1 I1 c' .. sysname_len
    return struct.pack(pack_str, 0x30, 0x23 + sysname_len + community_len, 0x02, 0x01, 0x00, 0x04, community_len,
        community, 0xA2, 0x1C + sysname_len, 0x02, 0x04, request_id, 0x02, 0x01, 0x00, 0x02,
        0x01, 0x00, 0x30, 0x0E + sysname_len, 0x30, 0x0C + sysname_len, varbind, obj_hi, obj_lo, 0x04, sysname_len, sysname)
end

function make_snmp_unpackstring(data)
    asn_header, pdu_len, version, comm_name, comm_len, excess = struct.unpack('> I1 I1 I3 I1 I1 s', data)  
    if (string.len(data) == 46) then
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. 'I1 I1 I2 I4 I8 I2 I2 I4 I4'
        return output_str
    elseif (string.len(data) == 51) then
        print("making the humongo packet")
        output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. 'I1 I1 I2 I4 I8 I2 I2 I6 I6 I3'
        return output_str
    elseif (string.len(data) == 43) then
        print("standard mib walk packet")
        output_str = '> I1 I1 I1 I4 c' .. comm_len .. 'I4 I4 I8 I4 I4 I3'
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
      print(string.len(data))
      if (string.len(data) == 46) then 
      snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, version, comm_name, comm_len, comm_string, req_type, req_len, dgaf1, req_id, dgaf2, varbind_list, varbind, obj_hi, obj_lo = struct.unpack(snmp_unpackstr, data)
        print(string.format("request type: %x request length: %x", req_type, req_len ))
        print(string.format("request id: %x", req_id))
        print(string.format("varbind_list: %x", varbind_list))
        print(string.format("varbind: %x", varbind))
        print(string.format("obj_hi: %x", obj_hi))
        print(string.format("obj_lo: %x", obj_lo))
        print(string.format("received community: %s", comm_string))
        if (obj_hi == 0x2b060102 and obj_lo == 0x1010500) then
          -- 1.3.6.1.2.1.1.5.0 - sysname
          if  req_type == 0xa1 then
            return_str = make_get_sysname_response('someplace good', comm_len, comm_string, req_id, varbind, 0x2b060102, 0x1010600)
            s:send(port, ip, return_str)
          else
            return_str = make_get_sysname_response('monitor1', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
            s:send(port, ip, return_str)
          end
        elseif (obj_hi == 0x2b060102 and obj_lo == 0x1010600 and req_type == 0xa0) then
          -- 1.3.6.1.2.1.1.6.0 - syslocation
          return_str = make_get_sysname_response('someplace good', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
          s:send(port, ip, return_str)
        end
      elseif (string.len(data) == 51) then
        print("we're dealing with the megapacket now!")
        snmp_unpackstr = make_snmp_unpackstring(data)
        print(snmp_unpackstr)
        print("we have the larger sized packet")
        asn_header, pdu_len, version, comm_name, comm_len, comm_string, req_type, req_len, dgaf1, req_id, dgaf2, varbind_list, varbind, obj_hi, obj_lo, obj_really_low = struct.unpack(snmp_unpackstr, data)
        print(string.format("request type: %x request length: %x", req_type, req_len ))
        print(string.format("request id: %x", req_id))
        print(string.format("varbind_list: %x", varbind_list))
        print(string.format("varbind: %x", varbind))
        print(string.format("obj_hi: %x", obj_hi))
        print(string.format("obj_lo: %x", obj_lo))
        print(string.format("received community: %s", comm_string))
            if (obj_hi == 0x104018f and obj_lo == 0x10020101) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.1.13
              return_str = make_temperature_integer_response(comm_len, comm_string, req_id)
              s:send(port, ip, return_str)
            elseif (obj_hi == 0x104018f and obj_lo == 0x10020103) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.3.13
              GET_18B20_TEMP()
              return_str = make_temperature_value_response(comm_len, comm_string, req_id)
              s:send(port, ip, return_str)
            elseif (obj_hi == 0x104018f and obj_lo == 0x10020102) then
              -- 1.3.6.1.4.1.2021.13.16.2.1.2.13 
              return_str = make_get_temp_name_response('Ambient', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
              s:send(port, ip, return_str)
            end
      elseif (string.len(data) == 43) then
        print("we have a snmpgetnext packet")
        snmp_unpackstr = make_snmp_unpackstring(data)
        asn_header, pdu_len, small_stuff, stuff, community_str, something, request_id, error_data, varbind_hi, varbind_lo, varbind_bottom = struct.unpack(snmp_unpackstr, data)
        print(string.format("asn header: 0x%x", asn_header))
        print(string.format("pdu_len: 0x%x", pdu_len))
        print(string.format("small_stuff: 0x%x", small_stuff))
        print(string.format("stuff: 0x%x", stuff))
        print(string.format("community_string: %s", community_str))
        print(string.format("something: 0x%x", something))
        print(string.format("request_id: 0x%x", request_id))
        print(string.format("error_info: 0x%x", error_data))
        print(string.format("varbind_hi: 0x%x", varbind_hi))
        print(string.format("varbind_lo: 0x%x", varbind_lo))
        print(string.format("varbind_bottom: 0x%x", varbind_bottom))
        if (varbind_hi == 0x30090605 and varbind_lo == 0x2b060102 and varbind_bottom == 0x10500) then
            print("sending sysname response to getnext")
            return_str = make_get_next_response_sysname(community_str, request_id, 'monitor1')
            s:send(port, ip, return_str)
            SNMP_WALK = true
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
    print("P="..present)  
    data = nil
    data = string.char(ow.read(PIN_18B20))
    for i = 1, 8 do
        data = data .. string.char(ow.read(PIN_18B20))
    end
    print(data:byte(1,9))
    crc = ow.crc8(string.sub(data,1,8))
    print("CRC="..crc)
    if crc == data:byte(9) then
       t = (data:byte(1) + data:byte(2) * 256) * 625
       TEMPERATURE = t / 10
       t1 = t / 10000
       print("Temperature="..t1.." Centigrade")
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
        print(string.format("0x%x, we have an 18B20, getting temp",addr:byte(1)))
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
