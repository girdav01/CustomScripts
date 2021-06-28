rule testhunt004
{
    meta:
 		weight = 1
		desc = "Hunt demo for Malicious Mutex"
		author = "Trend Micro, Inc."
 		date = "2021-06-28"
    strings:
        $a1 = "MyMaliciousMutexPOC"
	$a2 = "MyMaliciousMutexPOC" wide
	$a3 = "MyMaliciousMutexPOC" wide ascii
	$a4 = "MyMaliciousMutexPOC" nocase
    condition:
        $a2
}
