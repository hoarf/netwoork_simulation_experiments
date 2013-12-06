# "crindo o simulador" (construindo o objeto) -> -multicast on: habilitar multicast
set ns [new Simulator -multicast on]

# cause ACKs to get dropped
Queue set limit_ 6

#criando nodos
foreach k "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14" {
   set node($k) [$ns node]
}

#setando a saida de trace especifico do protocolo
set f [open out.tr w]
$ns trace-all $f

#setando a saida de trace que será usada pelo nam (semelhante entre protocolos)
set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 red
$ns color 2 green
$ns color 3 blue
$ns color 4 yellow
$ns color 5 LightBlue
$ns color 30 orange
$ns color 31 cyan

#procedimento para criacao de links (apenas para facilitar a tarefa)
proc makelinks { bw delay pairs } {
  global ns node
  foreach p $pairs {
    set src $node([lindex $p 0])
    set dst $node([lindex $p 1])


    # alinha abaixo eh que eh a importante
    $ns duplex-link $src $dst $bw $delay DropTail

    #questoes esteticas (para o nam)
    $ns duplex-link-op $src $dst orient [lindex $p 2]
  }
}



# chamadas para a funcao de criacao de links (declarada acima)
makelinks 1.5Mb 10ms {
  { 9 0 right-up }
  { 9 1 right }
  { 9 2 right-down }
  { 10 3 right-up }
  { 10 4 right }
  { 10 5 right-down }
  { 11 6 right-up }
  { 11 7 right }
  { 11 8 right-down }
}

makelinks 1.5Mb 40ms {
  { 12 9 right-up }
  { 12 10 right }
  { 12 11 right-down }
}

makelinks 1.5Mb 10ms {
  { 13 12 down }
}

makelinks 1.5Mb 50ms {
  { 14 12 right }
}




# definindo que as filas devem ser visiveis.
#Detalhe: chamada similar a usada para direcionamento grafico dos links.
# neste caso, define também o angulo da fila

$ns duplex-link-op $node(12) $node(14) queuePos 0.5
$ns duplex-link-op $node(10) $node(3) queuePos 0.5




#definicao do tipo de "gerencia" de multicast (prune e familiares)
set mproto DM
set mrthandle [$ns mrtproto $mproto {}]



#definicao de um novo grupo multicast
set grp [Node allocaddr]

# Cria agentes UDP com trafego CBR - transmissores de tráfego
  set udp [new Agent/UDP]
  $ns attach-agent $node(14) $udp
  $udp set fid_ 1

  set cbr [new Application/Traffic/CBR]
  $cbr attach-agent $udp
  $cbr set packetSize_ 500
  $cbr set rate_ 800k

  $udp set dst_addr_ $grp
  $udp set dst_port_ 0

$ns at 0.1 "$cbr start"

  set rcvr [new Agent/LossMonitor]
  for {set i 0} {$i<8} {incr i} {
    $ns attach-agent $node($i) $rcvr
    $ns at 0.5 "$node($i) join-group $rcvr $grp"
  }
  $ns at 1.0 "$node(7) leave-group $rcvr $grp"
  $ns at 1.2 "$node(6) leave-group $rcvr $grp"
  $ns at 2.0 "finish"

proc finish {} {
  global ns f
  $ns flush-trace
  close $f

  puts "running nam..."
  exec nam out.nam &
  exit 0
}

$ns run

