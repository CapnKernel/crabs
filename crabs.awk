#! /bin/gawk -f

# Call with -v DEBUG=1 to get debugging
# Call with -v MODE=local to emit local route statements
function mask(bits,     acc)
{
  acc = 0;
  for (i = 0; i < 32; i++)
  {
    acc = acc * 2;
    if (i < bits)
      acc = acc + 1;
  }
  return acc;
}

function ipstr2int(ip)
{
  split(ip, a, ".");
  acc = 0;
  for (n = 1; n <= 4; n++)
  {
    acc = acc * 256 + a[n];
  }
  return acc;
}

function int2ipstr(i,   acc)
{
  # print "int2ipstr: i=" i
  q = 4;
  while (1)
  {
     b = and(i, 255);
     acc = b acc;
     # print "q=" q, "i=" i, "b=" b, "acc=" acc
     if (q == 1)
      return acc;
    acc = "." acc;
    q--;
    i = rshift(i, 8);
  }
}

function report(ip, mask)
{
    if (MODE == 1)
    {
        if (mask == "255.255.255.255")
            print "route add -host", ip, "dev tun0";
        else
            print "route add -net", ip, "netmask", mask, "dev tun0";;
    }
    else
    {
        print "push \"route", ip, mask, "\""
    }
}

BEGIN {
    FS=","
# print mask(1);
# print mask(2);
# print mask(32);
# print ipstr2int("0.0.0.0");
# print ipstr2int("0.0.0.1");
# print ipstr2int("0.0.1.0");
# print ipstr2int("0.0.1.1");
# print ipstr2int("0.0.255.255");
# print ipstr2int("11.12.13.14");
#  print int2ipstr(ipstr2int("0.0.0.0"));
#  print int2ipstr(ipstr2int("0.0.0.1"));
#  print int2ipstr(ipstr2int("0.0.1.0"));
#  print int2ipstr(ipstr2int("0.0.1.1"));
#  print int2ipstr(ipstr2int("0.0.255.255"));
#  print int2ipstr(ipstr2int("11.12.13.14"));
#  exit;
}

# Strip comments

$1 ~ /^#/ {
    next
}

match($0, /(.*)\/([0-9][0-9]*)/, a) {
	name = a[1];
	bits = a[2];
    if (DEBUG)
      print "net: name=" name, "bits=" bits

    # print $1 $2;
    # cmd = "time nslookup " name
    cmd = "nslookup " name
    BLANKFOUND = 0
    FS = " "
# print "%", cmd
    while ((cmd | getline) > 0)
    {
        if ($0 == "")
        {
            BLANKFOUND = 1;
            continue;
        }

        if (BLANKFOUND && $1 == "Address:")
        {
			m = mask(bits);
            mstr = int2ipstr(m);
			ipint = ipstr2int($2);
            net = and(ipint, m);
            netstr = int2ipstr(net);
			if (DEBUG)
              print "ip=" $2, "m=" m, "ipint=" ipint, "net=" net, "netstr=" netstr;
            report(netstr, mstr);
			next;
		}
    }
    close(cmd);
    FS = ","
}

# It's a host
{
	name = $1
    if (DEBUG)
      print "host: name=" name

    # print $1 $2;
    # cmd = "time nslookup " name
    cmd = "nslookup " name
    BLANKFOUND = 0
    FS = " "
# print "%", cmd
    while ((cmd | getline) > 0)
    {
        if ($0 == "")
        {
            BLANKFOUND = 1;
            continue;
        }

        if (BLANKFOUND && $1 == "Address:")
        {
            report($2, "255.255.255.255");
        }
    }
    close(cmd);
    FS = ","
}

