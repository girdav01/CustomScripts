rule testhunt001
{
  
    meta:
 		weight = 1
		desc = "Hunt for api.mutinyhq.io"
		author = "Trend Micro, Inc."
 		date = "2020-03-02"
    strings:
        $a1 = "api.mutinyhq.io"
		$a2 = "https://api.mutinyhq.io/"
    condition:
        any of them
}
