rule testhunt004
{
    meta:
 		weight = 1
		desc = "Hunt demo for Malicious Mutex"
		author = "Trend Micro, Inc."
 		date = "2021-06-28"
    strings:
        $a1 = "AutoIt" wide
	$a2 = "MyMaliciousMutexPOC" wide
    condition:
        $a1 and $a2
}
