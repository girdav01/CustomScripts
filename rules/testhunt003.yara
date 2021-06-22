/*
   YARA Rule Set
   Author: Trend Micro
   Date: 2021-06-22
   Identifier: 
   Reference: 
*/

/* Rule Set ----------------------------------------------------------------- */

rule samples_putty {
   meta:
      description = "Demo rule - file putty.exe"
      author = "Trend Micro"
      date = "2021-06-22"
   strings:
      $s1 = "MIT Kerberos GSSAPI64.DLL" fullword ascii
      $s2 = "\\\\.\\pipe\\putty-connshare" fullword ascii
      $s3 = "SSH PRIVATE KEY PuTTY-User-Key-FENCRYPTED PRIVAT---- BEGIN SSH2 " fullword ascii
      $s4 = "CreateMutex(\"%s\") failed: %s" fullword ascii
      $s5 = "Agent-forwarding connection closed" fullword ascii
      $s6 = "i64.dll" fullword ascii
      $s7 = "Using GSSAPI from GSSAPI64.DLL" fullword ascii
      $s8 = "rlogin connection" fullword ascii
      $s9 = "config-proxy-command" fullword ascii
      $s10 = "6666666666666666666666666666666666666666666666666666666666666658" ascii /* hex encoded string 'fffffffffffffffffffffffffffffffX' */
      $s11 = "chacha20-poly1305@openssh.com" fullword ascii
      $s12 = " (core dumped)" fullword ascii
      $s13 = "Leaving host lookup to proxy of \"%s\" (for %s)" fullword ascii
      $s14 = "Unable to create pipes for proxy command: %s" fullword ascii
      $s15 = "GSSAPI import name failed - Bad service name; won't use GSS key exchange" fullword ascii
      $s16 = "in.len > 0 && in.len <= k - 2*HLEN - 2" fullword wide
      $s17 = "strncmp(pipename, \"\\\\\\\\.\\\\pipe\\\\\", 9) == 0" fullword wide
      $s18 = "Server also has %s host key%s, but we don't know %s" fullword ascii
      $s19 = "%s Command Line Error" fullword ascii
      $s20 = "https://sectigo.com/CPS0B" fullword ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      8 of them
}
