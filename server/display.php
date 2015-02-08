<?php

$LOG_DIRECTORY = 'c:/comportservice';
$list = scandir($LOG_DIRECTORY, SCANDIR_SORT_DESCENDING);

// yyyymm
$dir_current = intval(date("Ym"));
$dir_latest = null;

foreach($list as $v){
	
	if(!is_dir($LOG_DIRECTORY.'/'.$v)) continue;

	// check format 15/01/2015 14:30
	if (preg_match("/^[0-9]{4}(0[1-9]|1[0-2])$/",$v))
    {
		$tmp_dir = intval($v);
        if($tmp_dir > $dir_current) continue;
		$dir_latest = $v;
		break;
    }
}

echo 'latest:'.$dir_latest;


//print_r($files1);
//print_r($files2);

$result['status'] = '1';
$result['data'] = '2naja';
echo json_encode($result);
//sleep(100);
?>