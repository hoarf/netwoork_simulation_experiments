#
# Valter Roesler
# UFRGS - Instituto de Informática
# 
set delay 5ms  ;
set window_size 20 ;
set queue_size 30 ;

proc create-connection-fulltcp {n_src n_dst fid} {
  set ns [Simulator instance]  
  
  set src [new Agent/TCP/FullTcp]
  set sink [new Agent/TCP/FullTcp]
  $src set fid_ $fid
  $sink set fid_ $fid
  $ns attach-agent $n_src $src
  $ns attach-agent $n_dst $sink
  $ns connect $src $sink
  $sink listen
  return $src
}

proc avisaprog {} {
#Get an instance of the simulator
  set ns [Simulator instance]
  set now [$ns now]
  set tempo $now
  puts $now
  set tempo [expr $tempo+1]
  $ns at $tempo avisaprog
}

set ns [new Simulator]

$ns color 0 blue
$ns color 1 red

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

set f [open out-ex2-w=$window_size-q=$queue_size.tr w]
$ns trace-all $f
set nf [open out-ex2-w=$window_size-q=$queue_size.nam w]
$ns namtrace-all $nf

$ns duplex-link $n0 $n1 10Mb $delay DropTail
$ns duplex-link $n1 $n2 1Mb $delay DropTail
$ns duplex-link $n2 $n3 10Mb $delay DropTail
$ns queue-limit $n1 $n2 $queue_size

$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n1 $n2 queuePos -0.5

set tcp1 [create-connection-fulltcp $n0 $n3 0]
set ftp1 [$tcp1 attach-app FTP]
$tcp1 set window_ $window_size
puts [$tcp1 set window_]

$ns at 0.0 "avisaprog"
$ns at 0.1 "$ftp1 start"
$ns at 3.0 "finish"

proc finish {} {
    global ns f 
    global nf
    $ns flush-trace
    close $f
    close $nf
    puts "running nam..."
    exec nam out-ex2-w=20-q=30.nam
    exit 0
}

$ns run