<?php

# Refreshes the page after a certain duration
$url1=$_SERVER['REQUEST_URI'];
header("Refresh: 300; URL=$url1");

# Increments a integer varaible which is later used to call upon a webpage in an iFrame
  for ( $i = 1; $i < 8; $i++ ) {
    echo "<iframe src='./pies/pi$i.html' height='450' width='380' frameBorder='1'></iframe>";
}

?>