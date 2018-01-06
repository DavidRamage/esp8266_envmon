
SSID = "MY_SSID"
WPA_KEY = "MY_KEY"

MAX_CONNECT_ATTEMPTS = 100
CONNECT_ATTEMPT = 0

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
      end
	end)
end

function check_connection()
    if( CONNECT_ATTEMPT > MAX_CONNECT_ATTEMPTS) then
        print("failed to connect to wifi!")
    else
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

print("Starting system")
ip_address = wifi.sta.getip()

if ((ip_address ~= nil) and (ip_address ~= '0.0.0.0')) then
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, WPA_KEY)
else
    tmr.alarm(0,2500,0,check_connection) 
end
