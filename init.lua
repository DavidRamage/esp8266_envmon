WIFI_CONFIG = {}
WIFI_CONFIG.ssid = "SSID_NAME"
WIFI_CONFIG.pwd = "WPA2_KEY"
MAX_CONNECT_ATTEMPTS = 100
CONNECT_ATTEMPT = 0

PIN_18B20 = 4 
TEMPERATURE = 0.0

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
    output_str = '> I1 I1 I3 I1 I1 c' .. comm_len  .. 'I1 I1 I2 I4 I8 I2 I2 I4 I4'
    return output_str

end

function start_server()
   print("starting the server")
   udpSocket = net:createUDPSocket()
   udpSocket:listen(161, ip_address)
   udpSocket:on("receive", function(s, data, port, ip)
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
        return_str = make_get_sysname_response('monitor1', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
        s:send(port, ip, return_str)
      elseif (obj_hi == 0x2b060102 and obj_lo == 0x1010600) then
        -- 1.3.6.1.2.1.1.6.0 - syslocation
        return_str = make_get_sysname_response('someplace good', comm_len, comm_string, req_id, varbind, obj_hi, obj_lo)
        s:send(port, ip, return_str)
      elseif (obj_hi == 0x2b060104 and obj_lo == 0x18f650d) then
        return_str = make_temperature_integer_response(comm_len, comm_string, req_id)
        s:send(port, ip, return_str)
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

function GET_18B20_TEMP(addr)
    ow.reset(PIN_18B20)
    ow.select(PIN_18B20, addr)
    ow.write(PIN_18B20, 0x44, 1)
    tmr.delay(1000000)
    present = ow.reset(PIN_18B20)
    ow.select(PIN_18B20, addr)
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
        GET_18B20_TEMP(addr)
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
