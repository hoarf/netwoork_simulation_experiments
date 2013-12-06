# SIMULA��O DO USO DO PROTOCOLO RTP

# inicializa um novo simulador utilizando multicast
set ns [new Simulator -multicast on]

# inicializa os nodos 0, 1, 2 e 3 da simula��o
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns color 1 red

# pacotes de sincroniza��o (prune/graft packets)
$ns color 30 purple
$ns color 31 bisque

# informa��es de controle de qualidade (RTCP reports)
$ns color 32 green

set f [open rtp-out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

# estabelece as liga��es entre os nodos de 1.5Mb e � 10ms
$ns duplex-link $n0 $n1 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 1.5Mb 10ms DropTail

# informa o posicionamento das liga��es
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n1 $n3 orient right-down

# informa o �ngulo da pilha de pacotes
$ns duplex-link-op $n0 $n1 queuePos 0.5 

set mproto DM
set mrthandle [$ns mrtproto $mproto {}]
set group [Node allocaddr]

# inicializa as sess�es de RTP
set s0 [new Session/RTP]
set s1 [new Session/RTP]
set s2 [new Session/RTP]
set s3 [new Session/RTP]

# informa a taxa de tranmiss�o de cada sess�o
$s0 session_bw 400kb/s
$s1 session_bw 400kb/s
$s2 session_bw 400kb/s
$s3 session_bw 400kb/s

# vincula as sess�es aos nodos
$s0 attach-node $n0
$s1 attach-node $n1
$s2 attach-node $n2
$s3 attach-node $n3

# inicializa os grupos, as sess�es e come�a a transmitir
$ns at 0.4 "$s0 join-group $group"
$ns at 0.5 "$s0 start"
$ns at 0.6 "$s0 transmit 400kb/s"

$ns at 0.7 "$s1 join-group $group"
$ns at 0.8 "$s1 start"
$ns at 0.9 "$s1 transmit 400kb/s"

$ns at 1.0 "$s2 join-group $group"
$ns at 1.1 "$s2 start"
$ns at 1.2 "$s2 transmit 400kb/s"

$ns at 1.3 "$s3 join-group $group"
$ns at 1.4 "$s3 start"
$ns at 1.5 "$s3 transmit 400kb/s"

# finaliza a simula��o
$ns at 2.0 "finish"

# fun��o que gera o gr�fico de sa�da da simula��o
proc finish {} {
	global ns f nf
	$ns flush-trace
	close $f
	close $nf

	puts "running nam..."
	exec nam out.nam &
	exit 0
}

$ns run

