#
# Copyright (c) 1994-1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
# This product includes software developed by the Computer Systems
# Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#
# This file contains contrived scenarios and protocol agents
# to illustrate the basic srm suppression algorithms.
# It is not an srm implementation.
#
# $Header: /nfs/jade/vint/CVSROOT/ns-2/tcl/ex/srm-demo.tcl,v 1.14 2000/02/18 10:41:49 polly Exp $
#
# updated to use -multicast on by Lloyd Wood. dst_ needs improving

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
$ns color 30 black
$ns color 31 black


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




#classe extende outra interna ao ns. Um novo tipo de Agente.
Class Agent/Message/MC_Acker -superclass Agent/Message

#chamada a um metodo da classe  "Agent/Message"
Agent/Message/MC_Acker set packetSize_ 800


# implementacao do metodo "recv" da nova classe, recebendo o parametro "msg". Este metodo vai ser chamado,
# pelo simulador, quando um pacote chegar no nodo onde está o "agente".
Agent/Message/MC_Acker instproc recv msg {

  # guardando os atributos da mensagem (pacote) em variaveis locais
  set type      [lindex $msg 0]
  set from_addr [lindex $msg 1]
  set from_port [lindex $msg 2]
  set seqno     [lindex $msg 3]

  # jogando coisas na tela (cout)
  puts "Agent/Message/MC_Acker::recv $msg, $from_addr"

  # ajustando atributos do agente de acordo com o pacote recebido
  $self set dst_addr_ $from_addr
  $self set dst_port_ $from_port


  # usando um metodo do agente para mandar um pacote (ack) para o endereço de onde veio o pacote inicial
  # além do seqno (numero de sequencia)
  $self send "ack $from_addr $seqno"
}




#definicao de um novo agente, mas agora o emissor
Class Agent/Message/MC_Sender -superclass Agent/Message

# definindo o metodo (para recebimento de pacotes)
Agent/Message/MC_Sender instproc recv msg {
  $self instvar addr_ sent_

  #set addr $grp

  set type [lindex $msg 0]
  if { $type == "nack" } {
    set seqno [lindex $msg 2]
    if ![info exists sent_($seqno)] {
      $self send "data $seqno"
      set sent_($seqno) 1
    }
  }
}




# contrutor do sender
Agent/Message/MC_Sender instproc init {} {
  $self next
  $self set seqno_ 1
}


#rotina de "send" do sender
Agent/Message/MC_Sender instproc send-pkt {} {
  $self instvar seqno_ agent_addr_ agent_port_
  $self send "data $agent_addr_ $agent_port_ $seqno_"
  incr seqno_
}



#definicao de um novo grupo multicast
set grp [Node allocaddr]

#criacao do agente sender (instanciacao) e setagem de atributos
set sndr [new Agent/Message/MC_Sender]
$sndr set packetSize_ 1400
#definicao do endereco de destino (grupo)
$sndr set dst_addr_ $grp
$sndr set dst_port_ 0
$sndr set class_ 1




# vamos comecar a definir o que acontece e quando no decorrer da simulacao


# no tempo 1.0, ele attacha agentes ackeadores nos receptores [0..8]
$ns at 1.0 {
  global rcvr node
  foreach k "0 1 2 3 4 5 6 7 8" {
    set rcvr($k) [new Agent/Message/MC_Acker]
    $ns attach-agent $node($k) $rcvr($k)
    $rcvr($k) set class_ 2

    # importante: fazendo o join do nodo/agente no grupo
    $node($k) join-group $rcvr($k) $grp
  }
  $node(14) join-group $sndr $grp
}


# no inicio, ele estava usando um protcolo Full-Feedback, onde cada pacote que chega no receptor,
# é respondido com um ACK por este, ocasionando possivelmente um grande fluxo de pacotes e......
# .... IMPLOSÃO !!! Como acabar com este problema? uma das possibilidades é usando um protocolo
# NACK based, onde o receptr só enviará algum pacote de volta, quando detectar, ele mesmo, a perda.
# exemplo de deteccao de perda: o receptor recebeu o pacote 1 2 3 4 e depois o 6. Faltou o 5!!

Class Agent/Message/MC_Nacker -superclass Agent/Message
Agent/Message/MC_Nacker set packetSize_ 800
Agent/Message/MC_Nacker instproc recv msg {
  set type  [lindex $msg 0]
  set from  [lindex $msg 1]
  set port  [lindex $msg 2]
  set seqno [lindex $msg 3]

  puts "Agent/Message/MC_Nacker::recv $msg"
  $self instvar dst_ ack_
  if [info exists ack_] {

    #puts "I'm here in if"
    set expected [expr $ack_ + 1]

    puts "seq:$seqno     expected: $expected"
    if { $seqno > $expected } {
      puts "I'm here in IFIF"

      $self set dst_addr_ $from

      $self set dst_port_ $port

      $self send "nack $from $seqno"

      puts "sent"
    }
  }

  set ack_ $seqno
}

Class Agent/Message/MC_SRM -superclass Agent/Message
Agent/Message/MC_SRM set packetSize_ 800
Agent/Message/MC_SRM instproc recv msg {
  $self instvar dst_ ack_ nacked_ random_
  global grp
  set type  [lindex $msg 0]
  set from  [lindex $msg 1]
  set port  [lindex $msg 2]
  set seqno [lindex $msg 3]

  if { $type == "nack" } {
    set nacked_($seqno) 1
    return
  }
  if [info exists ack_] {
    set expected [expr $ack_ + 1]
    if { $seqno > $expected } {
      set dst_ $grp
      if [info exists random_] {
        global ns
        set r [expr ([ns-random] / double(0x7fffffff) + 0.1) * $random_]
        set r [expr [$ns now] + $r]
        $ns at $r "$self send-nack $from $seqno"
      } else {
        $self send "nack $grp $seqno"
      }
    }
  }
  set ack_ $seqno
}

Agent/Message/MC_SRM instproc send-nack { from seqno } {
  $self instvar nacked_ dst_
  global grp
  if ![info exists nacked_($seqno)] {
    set dst_ $grp
    set dst_port_ 0
    set dst_addr_ $grp

    puts "sending nack multicast"

    $self send "nack $grp $seqno"

    puts "sent"
  }
}



#no tempo 1.5, os agentes ACK são desatachados e sao atachado no lugar os agente NACK

$ns at 1.5 {
  global rcvr node
  foreach k "0 1 2 3 4 5 6 7 8" {
    $node($k) leave-group $rcvr($k) $grp
    $ns detach-agent $node($k) $rcvr($k)
    delete $rcvr($k)
    set rcvr($k) [new Agent/Message/MC_Nacker]
    $ns attach-agent $node($k) $rcvr($k)
    $rcvr($k) set class_ 3
    $node($k) join-group $rcvr($k) $grp
  }
}



#no tempo 3.0, os agentes NACK são desatachados e sao atachado no lugar os agente SRM

$ns at 3.0 {
  global rcvr node
  foreach k "0 1 2 3 4 5 6 7 8" {
    $node($k) leave-group $rcvr($k) $grp
    $ns detach-agent $node($k) $rcvr($k)
    delete $rcvr($k)
    set rcvr($k) [new Agent/Message/MC_SRM]
    $ns attach-agent $node($k) $rcvr($k)
    $rcvr($k) set class_ 3
    $node($k) join-group $rcvr($k) $grp
  }
}

$ns at 3.6 {
  global rcvr node
  foreach k "0 1 2 3 4 5 6 7 8" {
    $rcvr($k) set random_ 2
  }
}

$ns attach-agent $node(14) $sndr

foreach t {
  1.05
  1.08
  1.11
  1.14

  1.55
  1.58
  1.61
  1.64

  1.85
  1.88
  1.91
  1.94

  2.35
  2.38
  2.41
  2.44

  3.05
  3.08
  3.11
  3.14

  3.65
  3.68
  3.71
  3.74

} { $ns at $t "$sndr send-pkt" }

proc reset-rcvr {} {
  global rcvr
  foreach k "0 1 2 3 4 5 6 7 8" {
    $rcvr($k) unset ack_
  }
}

$ns at 2.345 "reset-rcvr"

Class Agent/Message/Flooder -superclass Agent/Message

Agent/Message/Flooder instproc flood n {
  while { $n > 0 } {
    $self send junk
    incr n -1
  }
}

set m0 [new Agent/Message/Flooder]
$ns attach-agent $node(10) $m0
set sink0 [new Agent/Null]
$ns attach-agent $node(3) $sink0
$ns connect $m0 $sink0
$m0 set class_ 4
$m0 set packetSize_ 1500

$ns at 1.977 "$m0 flood 10"

set m1 [new Agent/Message/Flooder]
$ns attach-agent $node(14) $m1
set sink1 [new Agent/Null]
$ns attach-agent $node(12) $sink1
$ns connect $m1 $sink1
$m1 set class_ 4
$m1 set packetSize_ 1500
$ns at 2.375 "$m1 flood 10"
$ns at 3.108 "$m1 flood 10"
$ns at 3.705 "$m1 flood 10"

$ns at 2.85 "reset-rcvr"

$ns at 3.6 "reset-rcvr"

$ns at 5.0 "finish"

proc finish {} {
  global ns f
  $ns flush-trace
  close $f

  puts "running nam..."
  exec nam out.nam &
  exit 0
}

$ns run

