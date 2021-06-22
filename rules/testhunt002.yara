rule testhunt002
{
    meta:
 		weight = 1
		desc = "Hunt demo for Putty"
		author = "Trend Micro, Inc."
 		date = "2021-06-22"
    strings:
        $a1 = "PuTTY"
	$a2 = "SSH-2"
	$a3 = "SSH-1"
	$a4 = "sshtty"
	$a5 = "config-ssh-xauthority"
	$a6 = "config-ssh-pty"
    condition:
        5 of them
}
